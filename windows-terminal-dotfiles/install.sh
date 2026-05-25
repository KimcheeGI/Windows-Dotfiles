#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_FILE="$SOURCE_DIR/settings.json"
TARGET_DIR="$HOME/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState"
TARGET_FILE="$TARGET_DIR/settings.json"

mkdir -p "$TARGET_DIR"
cp -f "$SOURCE_FILE" "$TARGET_FILE"
echo "Deployed Windows Terminal settings to $TARGET_FILE"
