# DXVK Upgrade Checklist

Target state:

- Keep Wine on `11.0`.
- Upgrade DXVK from `1.10.3` to the current stable upstream release `2.7.1`.
- Preserve the existing library bundle layout so the app keeps loading the runtime without code-path changes.

## File-by-File Plan

### 1. `Libraries/`

- Replace the bundled DXVK payload with the new build.
- Keep the existing `Wine/` layout intact.
- Preserve the archive name `Libraries.tar.gz` so the release workflow does not need URL changes.
- Verify the final bundle still contains the expected `DXVK` directory alongside the Wine runtime.

### 2. `docs/ReleaseWorkflow.md`

- Update the Wine Libraries release section to mention DXVK refreshes explicitly.
- Add a short note that Wine can remain pinned while DXVK is updated independently.
- Add a verification step for Steam, DirectX 9, and DirectX 11 smoke tests before publishing.

### 3. `CHANGELOG.md`

- Add a new unreleased or versioned entry describing the DXVK update.
- State the previous DXVK version and the new version.
- Call out any regressions, driver notes, or launcher fixes discovered during testing.

### 4. `README.md`

- Update any user-facing release notes or compatibility bullets if the DXVK update changes game compatibility expectations.
- If needed, mention the current bundled DXVK version in the key features or release notes area.

### 5. `WhiskyKit/Sources/WhiskyKit/WhiskyWine/WhiskyWineInstaller.swift`

- Verify the installer still expects the same `Libraries/` and `Wine/` layout.
- Do not change the install logic unless the bundle structure changes.
- If the runtime bundle gains a new version marker, update the version-checking code here.

### 6. `WhiskyKit/Sources/WhiskyKit/WhiskyWine/WhiskyWineVersion.swift`

- Leave unchanged unless the version plist schema changes.
- If you add new metadata fields for DXVK, extend the decoder/encoder here.

### 7. `WhiskyKit/Sources/WhiskyKit/Utils/DistributionConfig.swift`

- Leave unchanged if the release asset naming stays `Libraries.tar.gz`.
- Change this file only if the download URL or release naming scheme changes.

### 8. `WhiskyKit/Sources/WhiskyKit/Wine/Wine.swift`

- Verify DXVK installation into bottles still points at the correct runtime folder.
- Re-test the DXVK enable path after swapping the library bundle.
- Only edit this file if the DXVK folder layout or DLL handling changes.

### 9. `.github/workflows/Release.yml`

- No code change is required for a library-only DXVK update if the release asset name stays the same.
- Update this workflow only if you automate release notes or release asset validation.

### 10. `gh-pages/WhiskyWineVersion.plist` or the equivalent Pages-hosted version file

- Bump the library version to match the new DXVK bundle release.
- Keep the major/minor/patch version in sync with the Git tag used for the library release.
- Add an optional `dxvkVersion` field so the app can display the exact bundled DXVK release.
- This file is not in the main repo branch, so update it in the Pages branch or deployment source.

Example shape:

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

### 11. `appcast.xml`

- Usually no change for a library-only update.
- Update only if you also ship an application release.

## Release Steps

1. Build or obtain the macOS-compatible DXVK `2.7.1` bundle.
2. Replace the runtime bundle in `Libraries/`.
3. Confirm the archive still produces `Libraries.tar.gz`.
4. Update the release notes in `CHANGELOG.md`.
5. Publish the new `Libraries` GitHub Release.
6. Update the Pages-hosted version plist.
7. Smoke test:
   - Steam launch
   - one DX9 game
   - one DX11 game
   - launcher-heavy title
   - shader cache and first-run behavior

## Verification Checklist

- [ ] DXVK version is `2.7.1`
- [ ] Wine version remains `11.0`
- [ ] `Libraries.tar.gz` downloads correctly from the new release tag
- [ ] `WhiskyWineVersion.plist` matches the published release version
- [ ] Steam still launches and renders correctly
- [ ] DX9 and DX11 titles launch
- [ ] No regression in controller input or fullscreen toggling
- [ ] No unexpected change in shader cache behavior

## DXMT Follow-Up

- [ ] The per-bottle Direct3D backend selector defaults to DXVK.
- [ ] DXMT remains opt-in and experimental for Apple Silicon + Tahoe.
- [ ] DXMT smoke tests cover one DX9 title, one DX11 title, Steam, and a launcher-heavy game.
- [ ] DXMT diagnostics include the selected backend in bottle logs.
