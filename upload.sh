#!/bin/bash
set -e

TARGET_WEB="justofisker/rotmg-shot-tool:html5"
TARGET_WINDOWS="justofisker/rotmg-shot-tool:windows"

# Web Build
WEB_BUILD_DIR="$(mktemp -d)"
$GODOT_BIN --headless --export-release "Web" "$WEB_BUILD_DIR/index.html"
butler push "$WEB_BUILD_DIR" "$TARGET_WEB"
rm -rf "$WEB_BUILD_DIR"

# Windows Build
WINDOWS_BUILD_DIR="$(mktemp -d)"
$GODOT_BIN --headless --export-release "Windows Desktop" "$WINDOWS_BUILD_DIR/Just's Shot Tool.exe"
cp -r assets "$WINDOWS_BUILD_DIR/"
find "$WINDOWS_BUILD_DIR/assets" -type f -name "*.import" -delete
cp -r scripts "$WINDOWS_BUILD_DIR/"
find "$WINDOWS_BUILD_DIR/scripts" -type f -name "*.uid" -delete
mkdir "$WINDOWS_BUILD_DIR/scenes"
butler push "$WINDOWS_BUILD_DIR" "$TARGET_WINDOWS"
rm -rf "$WINDOWS_BUILD_DIR"
