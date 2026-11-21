#!/usr/bin/env bash
set -euo pipefail

# ARRY Network Counter (ANC) Build Script
# Builds native macOS application bundle with Universal Binary (arm64 + x86_64)

CONFIGURATION="${1:-Debug}"
SDK_PATH="$(xcrun --show-sdk-path)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== Building ARRY Network Counter ($CONFIGURATION) ==="
echo "Project Root: $PROJECT_ROOT"
echo "macOS SDK:    $SDK_PATH"

BUILD_ROOT="$PROJECT_ROOT/build/$CONFIGURATION"
APP_NAME="ARRY Network Counter"
APP_BUNDLE="$BUILD_ROOT/$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

# Clean build directory
rm -rf "$BUILD_ROOT"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

# Collect Swift sources
SWIFT_SOURCES=()
while IFS= read -r -d '' file; do
    SWIFT_SOURCES+=("$file")
done < <(find "$PROJECT_ROOT/ARRYNetworkCounter" -name "*.swift" -print0)

echo "Sources: ${#SWIFT_SOURCES[@]} Swift file(s)"

SWIFT_FLAGS=(-sdk "$SDK_PATH" -parse-as-library)
if [ "$CONFIGURATION" = "Release" ]; then
    SWIFT_FLAGS+=(-O)
else
    SWIFT_FLAGS+=(-Onone -g -D DEBUG)
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Compiling arm64 slice..."
swiftc -target arm64-apple-macos13.0 "${SWIFT_FLAGS[@]}" "${SWIFT_SOURCES[@]}" -o "$TMP_DIR/exec_arm64"

echo "Compiling x86_64 slice..."
swiftc -target x86_64-apple-macos13.0 "${SWIFT_FLAGS[@]}" "${SWIFT_SOURCES[@]}" -o "$TMP_DIR/exec_x86_64"

echo "Creating Universal Binary..."
lipo -create "$TMP_DIR/exec_arm64" "$TMP_DIR/exec_x86_64" -output "$MACOS_DIR/ARRYNetworkCounter"

echo "Copying Info.plist and resources..."
cp "$PROJECT_ROOT/ARRYNetworkCounter/Info.plist" "$CONTENTS_DIR/Info.plist"
echo -n "APPL????" > "$CONTENTS_DIR/PkgInfo"

if [ -d "$PROJECT_ROOT/ARRYNetworkCounter/Resources/Assets.xcassets" ]; then
    cp -R "$PROJECT_ROOT/ARRYNetworkCounter/Resources/Assets.xcassets" "$RESOURCES_DIR/"
fi

# Ad-hoc code sign bundle for local execution
codesign --force --deep --sign - "$APP_BUNDLE"

echo "=== Build Complete ==="
echo "App Bundle: $APP_BUNDLE"
lipo -info "$MACOS_DIR/ARRYNetworkCounter"
