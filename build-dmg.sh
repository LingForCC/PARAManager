#!/bin/bash

# Build script for PARAManager app packaging
# This script builds the app, creates the app bundle, and packages it as a DMG

set -e

# Configuration
APP_NAME="PARAManager"
BUNDLE_IDENTIFIER="com.yourcompany.PARAManager"
VERSION="1.0.0"
BUILD_DIR=".build"
DIST_DIR="dist"
APP_BUNDLE="$APP_NAME.app"
DMG_NAME="$APP_NAME-$VERSION.dmg"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting build process for $APP_NAME v$VERSION${NC}"

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
rm -rf "$BUILD_DIR" 2>/dev/null || true
rm -rf "$DIST_DIR" 2>/dev/null || true
rm -f "$DMG_NAME" 2>/dev/null || true

# Create directories
mkdir -p "$DIST_DIR"

echo -e "${YELLOW}📦 Building the app...${NC}"

# Build the app using Swift Package Manager
swift build -c release --product "$APP_NAME"

# Create app bundle structure
echo -e "${YELLOW}📁 Creating app bundle structure...${NC}"
APP_BUNDLE_PATH="$DIST_DIR/$APP_BUNDLE"
mkdir -p "$APP_BUNDLE_PATH/Contents/MacOS"
mkdir -p "$APP_BUNDLE_PATH/Contents/Resources"

# Copy the executable
cp -f "$BUILD_DIR/release/$APP_NAME" "$APP_BUNDLE_PATH/Contents/MacOS/"

# Copy Info.plist
cp -f "Info.plist" "$APP_BUNDLE_PATH/Contents/"

# Create PkgInfo file
echo "APPL????" > "$APP_BUNDLE_PATH/Contents/PkgInfo"

# Copy any additional resources if they exist
if [ -d "Resources" ]; then
    echo -e "${YELLOW}📋 Copying resources...${NC}"
    cp -R "Resources/"* "$APP_BUNDLE_PATH/Contents/Resources/"
fi

echo -e "${YELLOW}🔐 Code signing the app (if certificate exists)...${NC}"

# Try to code sign the app if a Developer ID certificate is available
if security find-identity -v -p codesigning | grep -q "Developer ID"; then
    # Extract the first Developer ID certificate
    CERTIFICATE=$(security find-identity -v -p codesigning | grep "Developer ID" | head -1 | awk -F'"' '{print $2}')
    
    if [ -n "$CERTIFICATE" ]; then
        echo -e "${GREEN}✅ Found certificate: $CERTIFICATE${NC}"
        codesign --force --deep --sign "$CERTIFICATE" --options runtime --entitlements Entitlements.plist "$APP_BUNDLE_PATH" || {
            echo -e "${YELLOW}⚠️  Code signing failed, continuing without signing${NC}"
        }
    else
        echo -e "${YELLOW}⚠️  No Developer ID certificate found, skipping code signing${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  No Developer ID certificate found, skipping code signing${NC}"
fi

echo -e "${YELLOW}💿 Creating DMG...${NC}"

# Create a temporary directory for DMG contents
DMG_TEMP_DIR="dmg_temp"
rm -rf "$DMG_TEMP_DIR"
mkdir -p "$DMG_TEMP_DIR"

# Copy the app to the temporary directory
cp -R "$APP_BUNDLE_PATH" "$DMG_TEMP_DIR/"

# Create a symlink to Applications
ln -s /Applications "$DMG_TEMP_DIR/Applications"

# Create the DMG
hdiutil create -volname "$APP_NAME $VERSION" -srcfolder "$DMG_TEMP_DIR" -ov -format UDZO "$DMG_NAME"

# Clean up temporary directory
rm -rf "$DMG_TEMP_DIR"

echo -e "${GREEN}✅ Build complete!${NC}"
echo -e "${GREEN}📦 App bundle created: $APP_BUNDLE_PATH${NC}"
echo -e "${GREEN}💿 DMG created: $DMG_NAME${NC}"

# Instructions for notarization
echo ""
echo -e "${YELLOW}📋 Next steps for distribution:${NC}"
echo "1. If you have an Apple Developer account, notarize the DMG:"
echo "   xcrun altool --notarize-app --primary-bundle-id \"$BUNDLE_IDENTIFIER\" --username \"your-apple-id@example.com\" --password \"app-specific-password\" --file \"$DMG_NAME\""
echo ""
echo "2. After notarization is complete, staple the ticket:"
echo "   xcrun stapler staple \"$DMG_NAME\""
echo ""
echo "3. Test the DMG on another Mac to ensure it works correctly"
echo ""
echo -e "${GREEN}🎉 Your app is ready for distribution!${NC}"
