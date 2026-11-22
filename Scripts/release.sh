#!/usr/bin/env bash
set -euo pipefail

# ARRY Network Counter (ANC) Release Script
# Builds Universal Binary (arm64 + x86_64), packages application bundle,
# discovers code signing identities, creates installable DMG, and verifies installation.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SDK_PATH="$(xcrun --show-sdk-path)"
DIST_DIR="$PROJECT_ROOT/dist"
APP_NAME="ARRY Network Counter"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
DMG_NAME="ARRY-Network-Counter.dmg"
DMG_PATH="$DIST_DIR/$DMG_NAME"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "=================================================="
echo " ARRY Network Counter — Distribution & Packaging  "
echo "=================================================="
echo "Project Root: $PROJECT_ROOT"
echo "macOS SDK:    $SDK_PATH"
echo "Dist Dir:     $DIST_DIR"
echo "Target DMG:   $DMG_PATH"

# -----------------------------------------------------------------------------
# Step 1: Pre-flight Verification & Testing
# -----------------------------------------------------------------------------
echo ""
echo "[1/8] Running Pre-Packaging Verification Suite..."
"$PROJECT_ROOT/Scripts/test.sh"

# -----------------------------------------------------------------------------
# Step 2: Clean Output & Staging Directories
# -----------------------------------------------------------------------------
echo ""
echo "[2/8] Cleaning distribution directory..."
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR" "$MACOS_DIR" "$RESOURCES_DIR"

# -----------------------------------------------------------------------------
# Step 3: Compile Universal Binary (arm64 + x86_64)
# -----------------------------------------------------------------------------
echo ""
echo "[3/8] Compiling Release Universal Binary..."

SWIFT_SOURCES=()
while IFS= read -r -d '' file; do
    SWIFT_SOURCES+=("$file")
done < <(find "$PROJECT_ROOT/ARRYNetworkCounter" -name "*.swift" -print0)

echo "  Sources: ${#SWIFT_SOURCES[@]} Swift file(s)"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

SWIFT_FLAGS=(-sdk "$SDK_PATH" -parse-as-library -O)

echo "  -> Compiling arm64 slice (macOS 13.0)..."
swiftc -target arm64-apple-macos13.0 "${SWIFT_FLAGS[@]}" "${SWIFT_SOURCES[@]}" -o "$TMP_DIR/exec_arm64"

echo "  -> Compiling x86_64 slice (macOS 13.0)..."
swiftc -target x86_64-apple-macos13.0 "${SWIFT_FLAGS[@]}" "${SWIFT_SOURCES[@]}" -o "$TMP_DIR/exec_x86_64"

echo "  -> Assembling Universal Mach-O binary..."
lipo -create "$TMP_DIR/exec_arm64" "$TMP_DIR/exec_x86_64" -output "$MACOS_DIR/ARRYNetworkCounter"
chmod 755 "$MACOS_DIR/ARRYNetworkCounter"

echo "  -> Verifying architecture slices:"
lipo -info "$MACOS_DIR/ARRYNetworkCounter"

# -----------------------------------------------------------------------------
# Step 4: Assemble Application Bundle & Resources
# -----------------------------------------------------------------------------
echo ""
echo "[4/8] Assembling application bundle resources..."

cp "$PROJECT_ROOT/ARRYNetworkCounter/Info.plist" "$CONTENTS_DIR/Info.plist"
echo -n "APPL????" > "$CONTENTS_DIR/PkgInfo"

if [ -f "$PROJECT_ROOT/ARRYNetworkCounter/Resources/AppIcon.icns" ]; then
    cp "$PROJECT_ROOT/ARRYNetworkCounter/Resources/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
fi

if [ -d "$PROJECT_ROOT/ARRYNetworkCounter/Resources/Assets.xcassets" ]; then
    cp -R "$PROJECT_ROOT/ARRYNetworkCounter/Resources/Assets.xcassets" "$RESOURCES_DIR/"
fi

mkdir -p "$RESOURCES_DIR/Documentation"
if [ -d "$PROJECT_ROOT/ARRYNetworkCounter/Resources/Documentation" ]; then
    cp -R "$PROJECT_ROOT/ARRYNetworkCounter/Resources/Documentation/"* "$RESOURCES_DIR/Documentation/"
fi

# Bundle Metadata Verification
echo "  -> Validating Info.plist bundle metadata..."
PLIST_BUDDY="/usr/libexec/PlistBuddy"
BUNDLE_ID="$($PLIST_BUDDY -c "Print :CFBundleIdentifier" "$CONTENTS_DIR/Info.plist")"
VERSION="$($PLIST_BUDDY -c "Print :CFBundleShortVersionString" "$CONTENTS_DIR/Info.plist")"
BUILD_NUM="$($PLIST_BUDDY -c "Print :CFBundleVersion" "$CONTENTS_DIR/Info.plist")"
MIN_OS="$($PLIST_BUDDY -c "Print :LSMinimumSystemVersion" "$CONTENTS_DIR/Info.plist")"
LS_UI_ELEM="$($PLIST_BUDDY -c "Print :LSUIElement" "$CONTENTS_DIR/Info.plist")"

if [ "$BUNDLE_ID" != "in.arrry.networkcounter" ]; then
    echo "ERROR: Invalid CFBundleIdentifier '$BUNDLE_ID'" >&2
    exit 1
fi
if [ "$MIN_OS" != "13.0" ]; then
    echo "ERROR: Invalid LSMinimumSystemVersion '$MIN_OS'" >&2
    exit 1
fi
if [ "$LS_UI_ELEM" != "true" ]; then
    echo "ERROR: LSUIElement must be true" >&2
    exit 1
fi

echo "  Bundle Identifier:       $BUNDLE_ID"
echo "  Marketing Version:       $VERSION"
echo "  Build Number:            $BUILD_NUM"
echo "  Minimum System Version:  $MIN_OS"
echo "  Menu Bar Agent (UIElem): $LS_UI_ELEM"

# -----------------------------------------------------------------------------
# Step 5: Code Signing & Hardened Runtime Discovery
# -----------------------------------------------------------------------------
echo ""
echo "[5/8] Code signing application bundle..."

# Discover available signing identity
DEV_ID_IDENTITY=""
if [ -n "${SIGNING_IDENTITY:-}" ]; then
    DEV_ID_IDENTITY="$SIGNING_IDENTITY"
else
    # Check if a Developer ID certificate is available in keychain
    DEV_ID_MATCH="$(security find-identity -v -p codesigning 2>/dev/null | grep "Developer ID Application" | head -n 1 || true)"
    if [ -n "$DEV_ID_MATCH" ]; then
        # Extract identity string between quotes
        DEV_ID_IDENTITY="$(echo "$DEV_ID_MATCH" | sed -n 's/.*"\(.*\)".*/\1/p')"
    fi
fi

if [ -n "$DEV_ID_IDENTITY" ]; then
    echo "  -> Signing with Developer ID: '$DEV_ID_IDENTITY' (Hardened Runtime enabled)..."
    codesign --force --deep --options runtime --timestamp --sign "$DEV_ID_IDENTITY" "$APP_BUNDLE"
else
    echo "  -> No Developer ID Application certificate detected in keychain."
    echo "  -> Applying ad-hoc code signature for local development & manual distribution testing..."
    codesign --force --deep --sign - "$APP_BUNDLE"
fi

echo "  -> Verifying code signature..."
codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE"
codesign -dv --verbose=2 "$APP_BUNDLE"

# -----------------------------------------------------------------------------
# Step 6: Prepare Staging Directory & Build DMG
# -----------------------------------------------------------------------------
echo ""
echo "[6/8] Building DMG installer ($DMG_NAME)..."

STAGING_DIR="$TMP_DIR/dmg_staging"
mkdir -p "$STAGING_DIR"

echo "  -> Staging application bundle..."
cp -R "$APP_BUNDLE" "$STAGING_DIR/"

echo "  -> Creating Applications symlink..."
ln -s /Applications "$STAGING_DIR/Applications"

# Volume icon if AppIcon.icns exists
if [ -f "$PROJECT_ROOT/ARRYNetworkCounter/Resources/AppIcon.icns" ]; then
    cp "$PROJECT_ROOT/ARRYNetworkCounter/Resources/AppIcon.icns" "$STAGING_DIR/.VolumeIcon.icns"
    if command -v SetFile >/dev/null 2>&1; then
        SetFile -a C "$STAGING_DIR" 2>/dev/null || true
    fi
fi

echo "  -> Generating compressed read-only UDZO disk image..."
hdiutil create \
    -volname "ARRY Network Counter" \
    -srcfolder "$STAGING_DIR" \
    -ov \
    -format UDZO \
    "$DMG_PATH"

echo "  -> DMG created at: $DMG_PATH"
DMG_SIZE="$(du -sh "$DMG_PATH" | awk '{print $1}')"
echo "  -> DMG File Size:  $DMG_SIZE"

# Sign DMG if Developer ID identity is available
if [ -n "$DEV_ID_IDENTITY" ]; then
    echo "  -> Signing DMG with Developer ID..."
    codesign --sign "$DEV_ID_IDENTITY" --timestamp "$DMG_PATH"
fi

# -----------------------------------------------------------------------------
# Step 7: Notarization (Conditional)
# -----------------------------------------------------------------------------
echo ""
echo "[7/8] Assessing Apple Notarization Status..."

if [ -n "${NOTARY_KEYCHAIN_PROFILE:-}" ] && [ -n "$DEV_ID_IDENTITY" ]; then
    echo "  -> Submitting DMG for notarization using profile '$NOTARY_KEYCHAIN_PROFILE'..."
    xcrun notarytool submit "$DMG_PATH" --keychain-profile "$NOTARY_KEYCHAIN_PROFILE" --wait
    echo "  -> Stapling notarization ticket to DMG..."
    xcrun stapler staple "$DMG_PATH"
    xcrun stapler validate "$DMG_PATH"
elif [ -n "${APPLE_ID:-}" ] && [ -n "${APP_PASSWORD:-}" ] && [ -n "${TEAM_ID:-}" ] && [ -n "$DEV_ID_IDENTITY" ]; then
    echo "  -> Submitting DMG for notarization using Apple ID '$APPLE_ID'..."
    xcrun notarytool submit "$DMG_PATH" --apple-id "$APPLE_ID" --password "$APP_PASSWORD" --team-id "$TEAM_ID" --wait
    echo "  -> Stapling notarization ticket to DMG..."
    xcrun stapler staple "$DMG_PATH"
    xcrun stapler validate "$DMG_PATH"
else
    echo "  -> Notarization skipped: No Apple Developer Program credentials configured."
    echo "  -> Build is packaged and verified as an Ad-Hoc / Personal Testing release."
fi

# -----------------------------------------------------------------------------
# Step 8: Verification & Installation Testing
# -----------------------------------------------------------------------------
echo ""
echo "[8/8] Performing DMG Mount & Installation Verification..."

echo "  -> Running hdiutil verify on disk image..."
hdiutil verify "$DMG_PATH"

MOUNT_DIR="$TMP_DIR/mount"
mkdir -p "$MOUNT_DIR"

echo "  -> Mounting disk image..."
ATTACH_INFO="$(hdiutil attach "$DMG_PATH" -nobrowse -readonly -mountpoint "$MOUNT_DIR")"
echo "  -> Mounted at: $MOUNT_DIR"

# Verify layout in mounted volume
if [ ! -d "$MOUNT_DIR/$APP_NAME.app" ]; then
    echo "ERROR: Mounted DMG is missing '$APP_NAME.app'" >&2
    hdiutil detach "$MOUNT_DIR"
    exit 1
fi

if [ ! -L "$MOUNT_DIR/Applications" ]; then
    echo "ERROR: Mounted DMG is missing Applications symlink" >&2
    hdiutil detach "$MOUNT_DIR"
    exit 1
fi

SYMLINK_TARGET="$(readlink "$MOUNT_DIR/Applications")"
if [ "$SYMLINK_TARGET" != "/Applications" ]; then
    echo "ERROR: Applications symlink points to '$SYMLINK_TARGET', expected '/Applications'" >&2
    hdiutil detach "$MOUNT_DIR"
    exit 1
fi

echo "  -> Layout Verified: App bundle and /Applications symlink present and valid."

# Test Drag-to-Applications Simulation
echo "  -> Testing installation copy from mounted DMG to test environment..."
INSTALL_TEST_DIR="$TMP_DIR/test_installed_app"
mkdir -p "$INSTALL_TEST_DIR"
cp -R "$MOUNT_DIR/$APP_NAME.app" "$INSTALL_TEST_DIR/"

INSTALLED_APP="$INSTALL_TEST_DIR/$APP_NAME.app"
INSTALLED_EXEC="$INSTALLED_APP/Contents/MacOS/ARRYNetworkCounter"

echo "  -> Verifying copied app executable..."
lipo -info "$INSTALLED_EXEC"
file "$INSTALLED_EXEC"

echo "  -> Verifying copied app resources..."
test -f "$INSTALLED_APP/Contents/Info.plist"
test -f "$INSTALLED_APP/Contents/Resources/AppIcon.icns"
test -f "$INSTALLED_APP/Contents/Resources/Documentation/SETUP_GUIDE.md"
test -f "$INSTALLED_APP/Contents/Resources/Documentation/USAGE_GUIDE.md"

echo "  -> Testing execution of copied application..."
"$INSTALLED_EXEC" &
TEST_PID=$!
sleep 3
if ps -p $TEST_PID >/dev/null 2>&1; then
    echo "  -> Application running successfully (PID: $TEST_PID)."
    kill -TERM $TEST_PID
    wait $TEST_PID 2>/dev/null || true
    echo "  -> Application terminated cleanly."
else
    echo "ERROR: Installed application failed to launch or crashed on startup" >&2
    hdiutil detach "$MOUNT_DIR"
    exit 1
fi

echo "  -> Unmounting DMG..."
hdiutil detach "$MOUNT_DIR"

echo ""
echo "=================================================="
echo " RELEASE PACKAGING COMPLETED SUCCESSFULLY!        "
echo "=================================================="
echo "Artifacts generated in $DIST_DIR:"
ls -lh "$DIST_DIR"
echo "=================================================="
