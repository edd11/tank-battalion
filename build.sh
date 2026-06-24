#!/bin/bash
# Tank Battalion - Build Script
# Uses committed dosbox.conf with pre-configured TASM toolchain

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONF_FILE="$SCRIPT_DIR/dosbox.conf"

echo "========================================"
echo " Tank Battalion - Build"
echo "========================================"
echo ""
echo "Building with TASM 4.1 + TLINK 7.1..."
echo ""

dosbox-staging -conf "$CONF_FILE" -c "build.bat" -c "exit"

echo ""
if [ -f "$SCRIPT_DIR/build/main.exe" ]; then
    echo "BUILD SUCCESSFUL: build/main.exe"
    ls -la "$SCRIPT_DIR/build/main.exe"
else
    echo "BUILD FAILED: main.exe not found in build/"
    exit 1
fi
