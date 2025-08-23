# PARAManager App Packaging Guide

This guide explains how to package your PARAManager SwiftUI app for direct distribution via DMG file.

## Prerequisites

### System Requirements
- macOS 14.0 or later
- Xcode Command Line Tools
- Swift 5.9 or later

### Apple Developer Account (Recommended)
For proper distribution, you should have:
- Apple Developer Program membership ($99/year)
- Developer ID Application certificate
- Developer ID Installer certificate

## Quick Start

### Basic Build (No Code Signing)
```bash
./build-dmg.sh
```

This will create a DMG file but users may see "unidentified developer" warnings.

### Full Build with Code Signing and Notarization
```bash
# 1. Build and sign the app
./build-dmg.sh

# 2. Notarize the DMG (replace with your Apple ID and app-specific password)
xcrun altool --notarize-app \
  --primary-bundle-id "com.yourcompany.PARAManager" \
  --username "your-apple-id@example.com" \
  --password "app-specific-password" \
  --file "PARAManager-1.0.0.dmg"

# 3. Staple the notarization ticket
xcrun stapler staple "PARAManager-1.0.0.dmg"
```

## Detailed Setup Instructions

### 1. Configure App Metadata

Edit `Info.plist` to update:
- `CFBundleIdentifier`: Change to your actual bundle identifier (e.g., `com.yourcompany.PARAManager`)
- `CFBundleShortVersionString`: Update version number
- `CFBundleVersion`: Update build number
- `NSHumanReadableCopyright`: Update copyright information
- `CFBundleIconFile`: Set your app icon name

### 2. Set Up Code Signing (Optional but Recommended)

#### Get Developer ID Certificate
1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. Navigate to Certificates, Identifiers & Profiles
3. Create a new certificate:
   - Type: Developer ID Application
   - Follow the instructions to create a Certificate Signing Request (CSR)
4. Download and install the certificate in Keychain Access

#### Verify Certificate Installation
```bash
security find-identity -v -p codesigning
```

You should see a "Developer ID Application" certificate in the output.

### 3. Configure Entitlements

Edit `Entitlements.plist` based on your app's needs:
- `com.apple.security.app-sandbox`: Enable App Sandbox (recommended for security)
- `com.apple.security.files.user-selected.read-only`: Allow reading user-selected files
- `com.apple.security.files.user-selected.read-write`: Allow writing to user-selected files
- `com.apple.security.network.client`: Allow network connections
- `com.apple.security.network.server`: Allow server functionality

Remove any entitlements your app doesn't need.

### 4. Add App Icon (Optional)

Create a `Resources` directory and add your app icon:
```bash
mkdir -p Resources
# Add your AppIcon.icns file here
```

### 5. Configure Build Script

Edit `build-dmg.sh` to update:
- `APP_NAME`: Your app name (default: "PARAManager")
- `BUNDLE_IDENTIFIER`: Your bundle identifier
- `VERSION`: Current version number

## Build Process

### What the Build Script Does

1. **Cleans previous builds**: Removes old build artifacts
2. **Builds the app**: Uses Swift Package Manager to create a release build
3. **Creates app bundle**: Sets up the proper macOS app structure
4. **Copies resources**: Includes Info.plist, entitlements, and other resources
5. **Code signs**: Signs the app if a Developer ID certificate is available
6. **Creates DMG**: Packages the app into a distributable disk image
7. **Adds symlink**: Includes a shortcut to the Applications folder

### Manual Build Steps

If you prefer to build manually:

```bash
# 1. Build the app
swift build -c release --product PARAManager

# 2. Create app bundle structure
mkdir -p dist/PARAManager.app/Contents/MacOS
mkdir -p dist/PARAManager.app/Contents/Resources

# 3. Copy executable
cp .build/release/PARAManager dist/PARAManager.app/Contents/MacOS/

# 4. Copy Info.plist
cp Info.plist dist/PARAManager.app/Contents/

# 5. Create PkgInfo
echo "APPL????" > dist/PARAManager.app/Contents/PkgInfo

# 6. Code sign (if you have a certificate)
codesign --force --deep --sign "Developer ID Application: Your Name" \
  --options runtime --entitlements Entitlements.plist \
  dist/PARAManager.app

# 7. Create DMG
hdiutil create -volname "PARAManager 1.0.0" \
  -srcfolder dist/PARAManager.app \
  -ov -format UDZO PARAManager-1.0.0.dmg
```

## Notarization Process

Notarization is required for smooth installation on modern macOS versions.

### 1. Create App-Specific Password
1. Go to [Apple ID Account](https://appleid.apple.com/)
2. Security → App-Specific Passwords
3. Generate a new password for notarization

### 2. Notarize the DMG
```bash
xcrun altool --notarize-app \
  --primary-bundle-id "com.yourcompany.PARAManager" \
  --username "your-apple-id@example.com" \
  --password "app-specific-password" \
  --file "PARAManager-1.0.0.dmg"
```

### 3. Check Notarization Status
```bash
xcrun altool --notarization-history 0 \
  --username "your-apple-id@example.com" \
  --password "app-specific-password"
```

### 4. Staple the Ticket
Once notarization is complete:
```bash
xcrun stapler staple "PARAManager-1.0.0.dmg"
```

## Testing Your Distribution

### 1. Test the App Bundle
```bash
open dist/PARAManager.app
```

### 2. Test the DMG
```bash
open PARAManager-1.0.0.dmg
```

### 3. Test on Another Mac
- Transfer the DMG to another Mac
- Mount and install the app
- Verify it runs without warnings (if notarized)

## Distribution

### 1. Version Management
Update version numbers in:
- `Info.plist` (CFBundleShortVersionString, CFBundleVersion)
- `build-dmg.sh` (VERSION variable)

### 2. Release Notes
Create a `RELEASE_NOTES.md` file for each release:
```markdown
# PARAManager v1.0.0

## New Features
- Feature 1
- Feature 2

## Bug Fixes
- Fixed issue with...
- Improved performance...

## System Requirements
- macOS 14.0 or later
```

### 3. Distribution Channels
- **Website**: Host the DMG on your website
- **GitHub Releases**: Upload DMG to GitHub releases
- **Direct Download**: Provide direct download links

### 4. Update Mechanism
Consider implementing an update mechanism:
- Sparkle framework for automatic updates
- Custom update checking
- Manual download notifications

## Troubleshooting

### Common Issues

#### "Code signing failed"
- Verify you have a Developer ID Application certificate
- Check that the certificate is not expired
- Ensure the certificate name matches exactly

#### "No such file or directory"
- Make sure all source files exist
- Check file paths in the build script
- Verify the app builds successfully with `swift build`

#### "Notarization failed"
- Check your Apple ID and password
- Verify the bundle identifier matches
- Ensure the app is properly code signed
- Check Apple's notarization logs for specific errors

#### "App won't open after installation"
- Check Gatekeeper settings
- Verify code signing
- Test notarization status
- Check system requirements

### Debug Commands

```bash
# Check app signature
codesign -vvv --deep --strict dist/PARAManager.app

# Check notarization status
xcrun stapler validate dist/PARAManager.app

# Verify DMG contents
hdiutil attach PARAManager-1.0.0.dmg
ls -la /Volumes/PARAManager\ 1.0.0/
hdiutil detach /Volumes/PARAManager\ 1.0.0/
```

## Best Practices

1. **Always test on a clean system** before distribution
2. **Keep your Developer ID certificates up to date**
3. **Notarize every release** for best user experience
4. **Include clear installation instructions** with your distribution
5. **Provide version information** in your app's About dialog
6. **Consider automatic updates** for better user experience
7. **Test on multiple macOS versions** if supporting older versions
8. **Keep your build process automated** to avoid human error

## Support

If you encounter issues with the packaging process:
1. Check the troubleshooting section above
2. Verify all prerequisites are met
3. Test each step individually
4. Consult Apple's documentation on:
   - Code Signing
   - App Notarization
   - DMG Creation
   - Swift Package Manager

---

*This guide covers the complete packaging process for distributing your PARAManager app via DMG files. For the most up-to-date information, always refer to Apple's official documentation.*
