# Project To-Dos

Prioritized improvement ideas for this fork.

## Critical

1. Update DXVK to the current stable release.
   - Current repo bundle: DXVK `1.10.3`
   - Current upstream stable: DXVK `2.7.1`
   - Keep Wine pinned to the current stable `11.0` line for now.
   - Verify common game paths after the update:
     - DirectX 9 titles
     - DirectX 11 titles
     - Steam startup
     - launcher-heavy games
     - shader cache behavior
   - Follow [docs/DXVKUpgradeChecklist.md](docs/DXVKUpgradeChecklist.md) for the file-by-file implementation plan.

## High Priority

2. Add CI checks for build, lint, and tests.
   - Run SwiftLint and SwiftFormat in CI.
   - Add a test job for WhiskyKit.
   - Block merges on failing checks.

3. Improve release version clarity.
   - Show app version, Wine version, and DXVK version clearly in release notes.
   - Add a small version manifest so users can see exactly what changed.
   - Keep rollback notes for older library bundles.

4. Add a compatibility matrix for games and launchers.
   - Track known-good launchers, games, and required settings.
   - Include notes for Steam, Epic, EA App, Rockstar, and Battle.net.
   - Record known regressions and required workarounds.

5. Improve diagnostics exports.
   - Include app version, Wine version, DXVK version, macOS version, bottle config, and recent logs.
   - Make the diagnostic archive easy to share in bug reports.

## Medium Priority

6. Add a fork-specific install and update path.
   - The repo should not depend on the original Whisky install flow.
   - Consider a dedicated download page, cask/tap, or app-side updater.

7. Add issue templates and triage labels.
   - Bug report template
   - Game compatibility template
   - Feature request template

8. Tighten contributor and build docs.
   - Add a clear local build guide.
   - Document how library bundles are produced and packaged.
   - Document how to test launcher and game compatibility.

9. Add per-bottle presets for common game cases.
   - Steam preset
   - launcher preset
   - controller-focused preset
   - troubleshooting preset

10. Add an experimental DXMT backend path for Apple Silicon and Tahoe.
    - App-side selector and launch plumbing are scaffolded.
    - In-app install/update action now opens the local DXMT folder when available and the release page when missing.
    - Keep DXVK as the default backend.
    - Gate DXMT behind an explicit per-bottle selector.
    - Test Steam, launchers, DX9 titles, and shader cache behavior before promoting it.

11. Make rollback safer for broken library updates.
    - Keep previous DXVK bundles available.
    - Make downgrade steps explicit in the app or docs.

## Lower Priority

12. Publish a machine-readable release manifest.
    - Useful for automation and future update tooling.

13. Add a simple compatibility database.
    - Store known-good game settings and per-game notes in a structured form.
