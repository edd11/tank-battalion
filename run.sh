#!/bin/bash
# Tank Battalion - Run Script
# Launches the compiled game in DOSBox using committed dosbox.conf

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ ! -f "$SCRIPT_DIR/build/main.exe" ]; then
    echo "No build/main.exe found. Run ./build.sh first."
    exit 1
fi

dosbox-staging -conf "$SCRIPT_DIR/dosbox.conf" -c "cd ..\\build" -c "main.exe"
