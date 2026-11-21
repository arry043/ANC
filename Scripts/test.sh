#!/usr/bin/env bash
set -euo pipefail

# ARRY Network Counter (ANC) Test Script
# Compiles and runs all unit test suites against Phase 02 models and coordinator

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SDK_PATH="$(xcrun --show-sdk-path)"
BUILD_DIR="$PROJECT_ROOT/build/Tests"

echo "=== Running ARRY Network Counter Unit Tests ==="
echo "Project Root: $PROJECT_ROOT"
echo "SDK Path:     $SDK_PATH"

mkdir -p "$BUILD_DIR"

# Collect application core and test sources (excluding main app entry point)
SOURCES=()
while IFS= read -r -d '' file; do
    # Skip the application @main entry point so TestRunner can define its own @main
    if [[ "$file" != *"ARRYNetworkCounterApp.swift"* ]]; then
        SOURCES+=("$file")
    fi
done < <(find "$PROJECT_ROOT/ARRYNetworkCounter" "$PROJECT_ROOT/Tests" -name "*.swift" -print0)

echo "Compiling ${#SOURCES[@]} source files for test execution..."

swiftc \
    -target arm64-apple-macos13.0 \
    -sdk "$SDK_PATH" \
    -parse-as-library \
    -Onone -g -D DEBUG \
    "${SOURCES[@]}" \
    -o "$BUILD_DIR/TestRunner"

echo "Executing test runner..."
"$BUILD_DIR/TestRunner"
