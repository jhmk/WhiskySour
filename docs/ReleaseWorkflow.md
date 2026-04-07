# Release Workflow Documentation

This document describes the process for publishing Wine Libraries and application updates to GitHub Releases and GitHub Pages.

## Overview

The Whisky fork uses the following infrastructure for distribution:

- **GitHub Pages** (`gh-pages` branch): Hosts version metadata and Sparkle appcast
- **GitHub Releases**: Hosts binary assets (Wine Libraries and application builds)

The most common library maintenance task is a DXVK refresh while keeping the
Wine runtime pinned to the current stable line. That keeps the scope of a
compatibility update small and makes regression testing easier to reason about.

## One-Time Setup: Sparkle EdDSA Keys

Before publishing any application releases, you must generate a new Sparkle EdDSA key pair. This is required because this fork cannot use the original Whisky project's signing keys.

### Generate Keys

1. **Using Sparkle's built-in tool** (if Sparkle is installed via SPM):
   ```bash
   # Navigate to the Sparkle package in DerivedData or use swift package plugin
   ./generate_keys
   ```

2. **Using the Sparkle framework** (if downloaded separately):
   ```bash
   ./Sparkle.framework/Versions/B/Resources/generate_keys
   ```

3. **Output**: The tool will generate:
   - **Private key**: Store securely (e.g., in a password manager or secure file). You'll need this to sign every release.
   - **Public key**: A base64-encoded string to put in `Info.plist`

### Update Info.plist

Replace the placeholder in `Whisky/Info.plist`:

```xml
<key>SUPublicEDKey</key>
<string>YOUR_GENERATED_PUBLIC_KEY_HERE</string>
```

### Store Private Key Securely

- **Never commit the private key** to version control
- Store it in a secure location (password manager, encrypted file, etc.)
- You'll need the private key path when running `generate_appcast` for releases

## Wine Libraries Release Process

### Prerequisites

1. Wine/GPTK binaries compiled and packaged as `Libraries.tar.gz`
2. DXVK build selected and staged in the bundle
3. Version number determined (e.g., `2.5.0`)

### Steps

1. **Update CHANGELOG.md**
   ```bash
   # Move items from [Unreleased] to new version section
   # Add release date in format YYYY-MM-DD
   ```
   
   Example:
   ```markdown
   ## [2.5.0] - 2026-01-10
   
   ### Added
   - New Wine libraries with GPTK support
   
   ### Fixed
   - Compatibility issues with macOS Tahoe
   ```

   If the release is a DXVK-only refresh, make that explicit in the notes:
   - Wine remains on the current stable line
   - DXVK was updated to the newer stable build
   - Include any smoke-test results for Steam and representative games

2. **Create GitHub Release**
   ```bash
   # Create a new release tag (e.g., v2.5.0)
   git tag v2.5.0
   git push origin v2.5.0
   ```

3. **Create Release on GitHub**
   - Go to https://github.com/jhmk/WhiskySour/releases/new
   - Select tag: `v2.5.0`
   - Title: `Wine Libraries v2.5.0`
   - Description: Copy release notes from CHANGELOG.md
   - Upload `Libraries.tar.gz` as a release asset
   - Confirm the archive contains the updated `DXVK/` payload
   - Publish release

4. **Update Version Plist on gh-pages**
   ```bash
   git checkout gh-pages
   # Edit WhiskyWineVersion.plist to match the new version
   # Update version numbers:
   #   major: 2
   #   minor: 5
   #   patch: 0
   # Optional: add dxvkVersion to record the bundled DXVK release, e.g. 2.7.1
   git add WhiskyWineVersion.plist
   git commit -m "Update WhiskyWine version to 2.5.0"
   git push origin gh-pages
   git checkout main
   ```

   Example plist shape:
   ```xml
   <key>version</key>
   <dict>
       <key>major</key>
       <integer>2</integer>
       <key>minor</key>
       <integer>5</integer>
       <key>patch</key>
       <integer>0</integer>
   </dict>
   <key>dxvkVersion</key>
   <string>2.7.1</string>
   ```

5. **Verify Download URL**
   The download URL will be:
   ```
   https://github.com/jhmk/WhiskySour/releases/download/v2.5.0/Libraries.tar.gz
   ```
   
   Note: The version in the URL must match the GitHub Release tag exactly.

6. **Smoke Test DXVK**
   - Launch Steam and confirm the client renders normally.
   - Start one known DirectX 9 title.
   - Start one known DirectX 11 title.
   - Verify DXVK toggles still apply correctly inside bottles.
   - Confirm shader cache behavior is unchanged after the update.

## Application Release Process

### Prerequisites

1. Application built and signed (if applicable)
2. Application packaged as `Whisky.app.zip`
3. Sparkle EdDSA signature generated for the release
4. Version number determined (e.g., `1.0.0`)

### Steps

1. **Update CHANGELOG.md**
   ```bash
   # Move items from [Unreleased] to new version section
   # Add release date in format YYYY-MM-DD
   # Update comparison links at bottom of file
   ```
   
   Example:
   ```markdown
   ## [1.0.0] - 2026-02-01
   
   ### Added
   - Initial release of Whisky application
   - Bottle management for Wine prefixes
   - Winetricks integration
   
   ### Fixed
   - Memory leak in bottle creation
   ```

2. **Generate Sparkle Signature**
   ```bash
   # Using Sparkle's generate_appcast tool
   # NOTE: ~/.ssh/sparkle_eddsa_key.pem is an example path. Replace it with the actual path
   # to your Sparkle EdDSA private key. See the Sparkle documentation for key generation:
   # https://sparkle-project.org/documentation/signing-updates/
   generate_appcast --ed-key-file ~/.ssh/sparkle_eddsa_key.pem path/to/releases/
   ```

3. **Create GitHub Release**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

4. **Create Release on GitHub**
   - Go to https://github.com/jhmk/WhiskySour/releases/new
   - Select tag: `v1.0.0`
   - Title: `Whisky v1.0.0`
   - Description: Copy release notes from CHANGELOG.md
   - Upload `Whisky.app.zip` as a release asset
   - Publish release

5. **Update appcast.xml on gh-pages**
   ```bash
   git checkout gh-pages
   # Edit appcast.xml to add new item:
   ```
   ```xml
   <item>
       <title>Version 1.0.0</title>
       <sparkle:releaseNotesLink>https://github.com/jhmk/WhiskySour/releases/tag/v1.0.0</sparkle:releaseNotesLink>
       <pubDate>Thu, 01 Jan 2026 00:00:00 +0000</pubDate>
       <enclosure url="https://github.com/jhmk/WhiskySour/releases/download/v1.0.0/Whisky.app.zip"
                  sparkle:version="1.0.0"
                  sparkle:shortVersionString="1.0.0"
                  length="SIZE_IN_BYTES"
                  type="application/octet-stream"
                  sparkle:edSignature="SIGNATURE_FROM_GENERATE_APPCAST"/>
   </item>
   ```
   ```bash
   git add appcast.xml
   git commit -m "Add Whisky v1.0.0 to appcast"
   git push origin gh-pages
   git checkout main
   ```

## Version Numbering

- **Wine Libraries**: Use semantic versioning (e.g., `2.5.0`)
  - Tag format: `v2.5.0`
  - Release title: `Wine Libraries v2.5.0`

- **Application**: Use semantic versioning (e.g., `1.0.0`)
  - Tag format: `v1.0.0`
  - Release title: `Whisky v1.0.0`

## URL Structure

### Wine Libraries
- Version check: `https://jhmk.github.io/WhiskySour/WhiskyWineVersion.plist`
- Download: `https://github.com/jhmk/WhiskySour/releases/download/v{VERSION}/Libraries.tar.gz`

### Application Updates
- Appcast: `https://jhmk.github.io/WhiskySour/appcast.xml`
- Download: `https://github.com/jhmk/WhiskySour/releases/download/v{VERSION}/Whisky.app.zip`

## Testing Checklist

Before publishing a release:

- [ ] CHANGELOG.md updated with release notes
- [ ] Version plist/appcast updated on gh-pages
- [ ] Release created on GitHub with correct tag
- [ ] Assets uploaded to release
- [ ] URLs accessible (test download links)
- [ ] Version check works in application
- [ ] Download succeeds in application
- [ ] Sparkle signature valid (for app releases)

## Troubleshooting

### Download Fails
- Verify release tag matches URL exactly (case-sensitive)
- Check asset filename matches URL (`Libraries.tar.gz` or `Whisky.app.zip`)
- Verify release is published (not draft)

### Version Check Fails
- Verify `WhiskyWineVersion.plist` is accessible at GitHub Pages URL
- Check plist format is valid XML
- Verify version numbers match expected format

### Sparkle Update Check Fails
- Verify `appcast.xml` is accessible at GitHub Pages URL
- Check XML format is valid
- Verify EdDSA signature is correct
- Check `SUPublicEDKey` in Info.plist matches signing key
