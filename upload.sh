#!/bin/bash
set -e

TARGET_WEB="justofisker/rotmg-shot-tool:html5"
TARGET_WINDOWS="justofisker/rotmg-shot-tool:windows"
TARGET_WINDOWS_ARM="justofisker/rotmg-shot-tool:windows-arm"
TARGET_LINUX="justofisker/rotmg-shot-tool:linux"
TARGET_LINUX_ARM="justofisker/rotmg-shot-tool:linux-arm"

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

# Windows Arm Build
WINDOWS_ARM_BUILD_DIR="$(mktemp -d)"
$GODOT_BIN --headless --export-release "Windows Arm Desktop" "$WINDOWS_ARM_BUILD_DIR/Just's Shot Tool.exe"
cp -r assets "$WINDOWS_ARM_BUILD_DIR/"
find "$WINDOWS_ARM_BUILD_DIR/assets" -type f -name "*.import" -delete
cp -r scripts "$WINDOWS_ARM_BUILD_DIR/"
find "$WINDOWS_ARM_BUILD_DIR/scripts" -type f -name "*.uid" -delete
mkdir "$WINDOWS_ARM_BUILD_DIR/scenes"
butler push "$WINDOWS_ARM_BUILD_DIR" "$TARGET_WINDOWS_ARM"
rm -rf "$WINDOWS_ARM_BUILD_DIR"

# Linux Build
LINUX_BUILD_DIR="$(mktemp -d)"
$GODOT_BIN --headless --export-release "Linux" "$LINUX_BUILD_DIR/Just's Shot Tool"
cp -r assets "$LINUX_BUILD_DIR/"
find "$LINUX_BUILD_DIR/assets" -type f -name "*.import" -delete
cp -r scripts "$LINUX_BUILD_DIR/"
find "$LINUX_BUILD_DIR/scripts" -type f -name "*.uid" -delete
mkdir "$LINUX_BUILD_DIR/scenes"
butler push "$LINUX_BUILD_DIR" "$TARGET_LINUX"
rm -rf "$LINUX_BUILD_DIR"

# Linux Arm Build
LINUX_ARM_BUILD_DIR="$(mktemp -d)"
$GODOT_BIN --headless --export-release "Linux Arm" "$LINUX_ARM_BUILD_DIR/Just's Shot Tool"
cp -r assets "$LINUX_ARM_BUILD_DIR/"
find "$LINUX_ARM_BUILD_DIR/assets" -type f -name "*.import" -delete
cp -r scripts "$LINUX_ARM_BUILD_DIR/"
find "$LINUX_ARM_BUILD_DIR/scripts" -type f -name "*.uid" -delete
mkdir "$LINUX_ARM_BUILD_DIR/scenes"
butler push "$LINUX_ARM_BUILD_DIR" "$TARGET_LINUX_ARM"
rm -rf "$LINUX_ARM_BUILD_DIR"
