# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Record upcoming frontend/diagnostics adjustments here before cutting the next release so the workflow remains ready-to-publish.

## [3.1.2] - 2026-04-07

### Added
- `scripts/build-and-run.sh` builds `WhiskeySour.app` and immediately opens it so the first launch downloads the Wine/DXVK runtime automatically.
- `scripts/fetch-runtime.sh` downloads Wine, DXVK, and cabextract into `Libraries/`, builds cabextract from source when needed, and packages them as `Libraries.tar.gz` so releases can upload the bundle effortlessly. Cached tarballs are reused so repeated runs skip already-downloaded archives.
- Wine URL updated to `wine-stable-11.0-osx64.tar.xz` to match the current Gcenx release.
- Cabextract download now tries each URL, skips any failing download, and copies the first executable it finds into `Libraries/cabextract`.
 - The helper now copies the built `WhiskeySour.app` into the repo root so users can launch the bundle without digging through DerivedData.

## [3.1.3] - 2026-04-07

### Changed
- Renamed the bundle and documentation from “Whisky” to “WhiskeySour” so the fork’s branding stays consistent across the app and docs.
- Added `WhiskyWineVersion.plist` (version 3.1.3, DXVK 2.7.1) so the installer only checks this repo for updates.
- Removed the automatic Wine runtime update check (`shouldUpdateWhiskyWine`) so the app relies solely on the published `WhiskyWineVersion.plist` from this repo.
## [3.1.1] - 2026-04-07

### Changed
- Upgraded DXVK from `1.10.3` to `2.7.1` for improved performance and compatibility
- Kept Wine pinned to `11.0` stable line
- Surfaced the bundled DXVK release in the installer logs and DXVK config UI

## [3.1.0] - 2026-04-07

### Added
- Experimental DXMT backend plumbing for Apple Silicon and Tahoe bottles
- In-app DXMT install/update action with local folder reveal and release-page fallback
- Fork-specific bundle identifiers and distribution URLs for `jhmk/WhiskySour`

### Changed
- Kept DXVK as the default Direct3D backend while exposing DXMT as opt-in
- Preserved Wine `11.0` while refreshing the DXVK release workflow and metadata plumbing
- Updated the WhiskySour fork release notes, docs, and diagnostics to reflect the new backend and fork namespace

### Added
- Terminal application selection: choose between Terminal, iTerm2, or Warp (Refs #47, upstream #911)
- Duplicate bottle feature for cloning bottles without export/import (Refs #47, upstream #822)
- App Nap management: disable macOS process throttling for better game performance (Refs #47, upstream #1297)
- Controller & Input Compatibility settings for game controller detection issues (Issue #42)
- Toast notifications showing launch success/failure feedback (Refs #49)
- Archive progress indicator with toast notifications for bottle export (Refs #49, upstream #827)
- Icon caching for faster program list loading (Refs #49, upstream #941)
- Improved UX for unavailable bottles with warning icon and quick remove button (Refs #49, upstream #1039)
- Retry button for failed config values (Build Version, Retina Mode, DPI) (Refs #49, upstream #967)
- Comprehensive Launcher Compatibility System including detection, diagnostics, and configuration
- Stability diagnostics export for crash/freeze reports (Refs #40)
- WhiskyWine download/install diagnostics with copy-to-clipboard workflow (Issue #63)
- SwiftFormat integration for automated code formatting
- DocC documentation for WhiskyKit public API
- Code coverage reporting and badges
- GitHub Pages and Releases infrastructure
- WhiskyKit test infrastructure and initial test suite
- Dependabot configuration for dependency updates

### Changed
- Refactored shared program launch logic into reusable `LaunchResult` and `launchWithUserMode()` (Issue #68)
- Refactored `BottleSettings` and `Wine` modules into smaller, focused components
- Replaced `print()` statements with `os.log` Logger for better debugging
- Consolidated CI workflows for improved efficiency
- Implemented proper thread safety by removing `@unchecked Sendable` usage
- Raised minimum deployment target from macOS 14 (Sonoma) to macOS 15 (Sequoia)
- AVX toggle and Sequoia compatibility mode are now always visible (no longer gated by OS version)

### Fixed
- Fixed Terminal launch (shift-click) producing malformed commands due to double-escaping (Issue #71)
- Fixed localization fallback showing raw keys to non-English users (Refs #49)
- Fixed WhiskyCmd `run` command not launching programs (now uses Wine directly) (Refs #49, upstream #1088, #1140)
- Corrected Dependabot Swift configuration
- Capped Wine process logs and pruned old logs to prevent excessive disk usage (Issue #46)
- Surface bottle creation failures with diagnostic information (Issue #61)
- Fixed winetricks dependency installs failing when %AppData% is empty (Issue #64)
- Fixed hardcoded "crossover" username in user profile path detection
- Added Wine prefix validation before running winetricks with repair option

### Security
- Process environment logging now records keys only (not values) to avoid persisting secrets in logs

### Removed
- Unmaintained CLI dependencies (SwiftyTextTable, Progress.swift)
- Removed `#available(macOS 15, *)` availability checks as macOS 15 is now the minimum

### Documentation
- Added comprehensive Launcher Troubleshooting and Steam Compatibility guides
- Removed obsolete Markdown files from the root and `docs/` directory
- Updated `README.md` and `CONTRIBUTING.md` to reflect current project state
- Consolidated documentation into the `docs/` directory

## [3.0.0] - 2026-01-18 (Wine Libraries)

### Changed
- Upgraded Wine from 7.7 to 11.0 (Gcenx stable build) for improved application compatibility
- Updated DXVK to macOS-compatible v1.10.3

### Fixed
- Steam "steamwebhelper is not responding" error caused by stubbed WSALookupServiceBegin (Issue #72)
- Improved networking stack for better launcher compatibility

## [2.5.0] - 2026-01-10

### Added
- Initial release of Whisky Wine binaries for this fork
- Wine/GPTK libraries packaged as `Libraries.tar.gz`
- GitHub Pages hosting for version metadata
- Sparkle appcast support for automatic updates
- Release workflow documentation

### Changed
- Fork setup with new distribution infrastructure
- Updated GitHub Pages URLs for the frankea fork

### Documentation
- Added `RELEASE_WORKFLOW.md` for publishing releases
- Added `DOCUMENTATION_AUDIT.md` for tracking documentation status
- Updated `README.md` with fork-specific information

---

## Categories Guide

When adding entries to this changelog, use the following categories:

- **Added** - New features
- **Changed** - Changes in existing functionality
- **Deprecated** - Soon-to-be removed features
- **Removed** - Now removed features
- **Fixed** - Bug fixes
- **Security** - Vulnerability fixes
- **Documentation** - Documentation-only changes

[Unreleased]: https://github.com/jhmk/WhiskySour/compare/v3.1.0...HEAD
[3.1.0]: https://github.com/jhmk/WhiskySour/releases/tag/v3.1.0
[3.0.0]: https://github.com/jhmk/WhiskySour/releases/tag/v3.0.0
[2.5.0]: https://github.com/jhmk/WhiskySour/releases/tag/v2.5.0
