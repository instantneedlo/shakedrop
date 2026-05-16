#!/bin/bash
set -e

APP_NAME="ShakeDrop"
BUILD_DIR=".build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
CONTENTS="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS/MacOS"
RESOURCES_DIR="$CONTENTS/Resources"

echo "🔨 编译 $APP_NAME (Release)..."
swift build -c release

echo "📦 创建 App Bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# 查找编译产物
BINARY=$(find "$BUILD_DIR" -name "$APP_NAME" -type f -not -path "*.dSYM*" | grep release | head -1)
if [ -z "$BINARY" ]; then
    echo "❌ 找不到编译产物"
    exit 1
fi

cp "$BINARY" "$MACOS_DIR/$APP_NAME"
cp "Resources/Info.plist" "$CONTENTS/Info.plist"

if [ -f "Resources/AppIcon.icns" ]; then
    cp "Resources/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
fi

echo ""
echo "✅ 完成: $APP_BUNDLE"
echo ""
echo "双击运行:"
echo "  open $(dirname "$APP_BUNDLE")"
echo ""
echo "安装到 /Applications:"
echo "  cp -r \"$APP_BUNDLE\" /Applications/"
