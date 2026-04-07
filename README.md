<div align="center">

# WhiskeySour 🥃
  *Wine but a bit stronger*

  > **Community Fork** - This is an independent fork maintained by [@jhmk](https://github.com/jhmk).
  > Not affiliated with the original Whisky project or getwhisky.app.

  ![](https://img.shields.io/github/actions/workflow/status/jhmk/WhiskySour/CI.yml?style=for-the-badge&label=CI)
  [![](https://img.shields.io/codecov/c/github/jhmk/WhiskySour?style=for-the-badge&logo=codecov&label=Coverage)](https://codecov.io/gh/jhmk/WhiskySour)
  [![](https://img.shields.io/github/issues/jhmk/WhiskySour?style=for-the-badge)](https://github.com/jhmk/WhiskySour/issues)
  [![Documentation](https://img.shields.io/badge/Documentation-DocC-blue?style=for-the-badge)](https://jhmk.github.io/WhiskySour/documentation/whiskykit/)
</div>

## Overview

WhiskeySour provides a clean and easy-to-use graphical wrapper for Wine built in native SwiftUI. You can make and manage bottles, install and run Windows apps and games, and unlock the full potential of your Mac with no technical knowledge required.

<img width="650" alt="Config" src="./images/config-screenshot.png">

*Familiar UI that integrates seamlessly with macOS*

<div align="right">
  <img width="650" alt="New Bottle" src="./images/new-bottle-screenshot.png">

  *One-click bottle creation and management*
</div>

<img width="650" alt="debug" src="./images/debug-screenshot.png">

*Debug and profile with ease*

---

## Key Features

- **Wine 11.0** - Latest stable Wine with improved compatibility and networking
- **DXVK 2.7.1** - Direct3D-to-Vulkan translation layer for improved graphics performance
- **Launcher Compatibility** - Built-in support for Steam, Epic, EA App, Rockstar, Battle.net, and more
- **Experimental DXMT Backend** - Optional Metal-based Direct3D backend for Apple Silicon and Tahoe
- **Controller Support** - SDL environment variable controls for gamepad detection and mapping issues

## Build & run from source

- Clone the repo, then run `scripts/build-and-run.sh`. It builds `WhiskeySour.app` via `xcodebuild` and immediately opens it so the installer can download `Libraries.tar.gz` (attached to the `v3.1.1` release) automatically into `~/Library/Application Support/com.jhmk.WhiskySour/Libraries/`.
- The runtime download only runs the first time; future launches use the locally cached Wine/DXVK bundle. Re-running the script rebuilds the app if you change code.
- **Stability Diagnostics** - One-click diagnostic reports for troubleshooting crashes and freezes
- **Native SwiftUI** - Beautiful, familiar macOS interface

## System Requirements

- **CPU**: Apple Silicon (M-series chips)
- **OS**: macOS Tahoe 26.0 or later

## Installation

Download the latest release from the [Releases page](https://github.com/jhmk/WhiskySour/releases).

> **Note:** This fork is not available via Homebrew. The `brew install --cask whisky` command installs the original Whisky project, not this fork.

## Documentation

WhiskyKit, the core framework powering Whisky, has comprehensive API documentation:

- **[WhiskyKit API Documentation](https://jhmk.github.io/WhiskySour/documentation/whiskykit/)** - Full API reference with usage examples
- **[Getting Started Guide](https://jhmk.github.io/WhiskySour/documentation/whiskykit/gettingstarted)** - Learn how to integrate WhiskyKit
- **[Architecture Overview](https://jhmk.github.io/WhiskySour/documentation/whiskykit/architecture)** - Understand how WhiskyKit components work together

### Troubleshooting

- **[Launcher Troubleshooting](docs/LauncherTroubleshooting.md)** - Fix issues with Steam, Epic, Battle.net, etc.
- **[Steam Compatibility Guide](docs/SteamCompatibility.md)** - Detailed guide for Steam on Whisky
- **[Stability Troubleshooting](docs/StabilityTroubleshooting.md)** - Diagnose crashes, freezes, reboots, and kernel panics
- **Controller Issues** - Enable "Controller Compatibility Mode" in Bottle Config → Controller & Input
- **[Game Support Wiki](https://github.com/jhmk/WhiskySour/wiki/Game-Support)** - Community-maintained game compatibility list

---

## Credits & Acknowledgments

Whisky is possible thanks to the magic of several projects:

- [msync](https://github.com/marzent/wine-msync) by marzent
- [DXVK-macOS](https://github.com/Gcenx/DXVK-macOS) by Gcenx and doitsujin
- [MoltenVK](https://github.com/KhronosGroup/MoltenVK) by KhronosGroup
- [Sparkle](https://github.com/sparkle-project/Sparkle) by sparkle-project
- [SemanticVersion](https://github.com/SwiftPackageIndex/SemanticVersion) by SwiftPackageIndex
- [swift-argument-parser](https://github.com/apple/swift-argument-parser) by Apple
- [SwiftTextTable](https://github.com/scottrhoyt/SwiftyTextTable) by scottrhoyt
- [CrossOver](https://www.codeweavers.com/crossover) by CodeWeavers and WineHQ
- D3DMetal by Apple

Special thanks to Gcenx, ohaiibuzzle, Nat Brown, and [Isaac Marovitz](https://github.com/IsaacMarovitz) (original author) for their support and contributions!

---

<table>
  <tr>
    <td>
        <picture>
          <source media="(prefers-color-scheme: dark)" srcset="./images/cw-dark.png">
          <img src="./images/cw-light.png" width="500">
        </picture>
    </td>
    <td>
        Whisky doesn't exist without CrossOver. Support the work of CodeWeavers using our <a href="https://www.codeweavers.com/store?ad=1010">affiliate link</a>.
    </td>
  </tr>
</table>
