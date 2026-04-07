//
//  WhiskyWineInstaller.swift
//  WhiskyKit
//
//  This file is part of Whisky.
//
//  Whisky is free software: you can redistribute it and/or modify it under the terms
//  of the GNU General Public License as published by the Free Software Foundation,
//  either version 3 of the License, or (at your option) any later version.
//
//  Whisky is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
//  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//  See the GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along with Whisky.
//  If not, see https://www.gnu.org/licenses/.
//

import Foundation
import os
import SemanticVersion

private let logger = Logger(subsystem: Bundle.whiskyBundleIdentifier, category: "WhiskyWineInstaller")

/// Manages the installation and updates of the WhiskyWine runtime.
///
/// `WhiskyWineInstaller` handles downloading, installing, and managing the
/// Wine runtime that Whisky uses to run Windows applications. It provides
/// version checking, update detection, and installation/uninstallation.
///
/// ## Overview
///
/// WhiskyWine is a custom Wine build bundled with Whisky. This class manages
/// its lifecycle within the application's Library directory.
///
/// ## Checking Installation Status
///
/// ```swift
/// if WhiskyWineInstaller.isWhiskyWineInstalled() {
///     if let version = WhiskyWineInstaller.whiskyWineVersion() {
///         print("WhiskyWine version: \(version)")
///     }
/// } else {
///     // Prompt user to install
/// }
/// ```
///
/// ## Installing WhiskyWine
///
/// ```swift
/// // After downloading the tarball
/// WhiskyWineInstaller.install(from: downloadedTarballURL)
/// ```
///
/// ## Topics
///
/// ### File Locations
/// - ``applicationFolder``
/// - ``libraryFolder``
/// - ``binFolder``
///
/// ### Installation Status
/// - ``isWhiskyWineInstalled()``
/// - ``whiskyWineInfo()``
/// - ``whiskyWineVersion()``
/// - ``whiskyWineDXVKVersion()``
///
/// ### Installation Management
/// - ``install(from:)``
/// - ``uninstall()``
public class WhiskyWineInstaller {
    /// The root application support folder for Whisky.
    ///
    /// Located at `~/Library/Application Support/{bundle-identifier}/`.
    public static let applicationFolder = FileManager.default.urls(
        for: .applicationSupportDirectory, in: .userDomainMask
    )[0].appending(path: Bundle.whiskyBundleIdentifier)

    /// The folder containing all library files including Wine and DXVK.
    ///
    /// Located at `~/Library/Application Support/{bundle-identifier}/Libraries/`.
    public static let libraryFolder = applicationFolder.appending(path: "Libraries")

    /// The URL to the Wine binary directory.
    ///
    /// This folder contains `wine64`, `wineserver`, and other Wine executables.
    public static let binFolder: URL = libraryFolder.appending(path: "Wine").appending(path: "bin")

    /// The folder containing the optional DXMT bundle.
    public static let dxmtFolder: URL = libraryFolder.appending(path: "DXMT")

    /// Checks whether WhiskyWine is currently installed.
    ///
    /// - Returns: `true` if WhiskyWine is installed and has a valid version file.
    public static func isWhiskyWineInstalled() -> Bool {
        whiskyWineVersion() != nil
    }

    /// Checks whether the optional DXMT bundle is installed alongside WhiskyWine.
    public static func isDXMTInstalled() -> Bool {
        FileManager.default.fileExists(atPath: dxmtFolder.path)
    }

    /// Installs WhiskyWine from a downloaded tarball.
    ///
    /// This method extracts the WhiskyWine tarball to the application support
    /// directory. If WhiskyWine is already installed, it is replaced.
    ///
    /// - Parameter from: The URL to the downloaded tarball file.
    /// - Note: The tarball is NOT deleted after extraction. Call ``cleanupTarball(at:)``
    ///   after verifying installation success with ``isWhiskyWineInstalled()``.
    ///
    /// - Important: Ensure the tarball is from a trusted source.
    public static func install(from: URL) {
        do {
            // Verify tarball exists before modifying application folder.
            // This prevents data loss if the OS has cleaned up the temp file.
            guard FileManager.default.fileExists(atPath: from.path) else {
                logger.error("Tarball not found at \(from.path) - cannot install")
                return
            }

            if !FileManager.default.fileExists(atPath: applicationFolder.path) {
                try FileManager.default.createDirectory(at: applicationFolder, withIntermediateDirectories: true)
            } else {
                // Recreate it
                try FileManager.default.removeItem(at: applicationFolder)
                try FileManager.default.createDirectory(at: applicationFolder, withIntermediateDirectories: true)
            }

            try Tar.untar(tarBall: from, toURL: applicationFolder)
        } catch {
            logger.error("Failed to install WhiskyWine: \(error.localizedDescription)")
        }
    }

    /// Removes the installation tarball after successful installation.
    ///
    /// Call this method only after ``isWhiskyWineInstalled()`` returns `true`
    /// to ensure the tarball is preserved for retry attempts if installation fails.
    ///
    /// - Parameter url: The URL to the tarball file to remove.
    public static func cleanupTarball(at url: URL) {
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
        } catch {
            logger.warning("Failed to cleanup tarball: \(error.localizedDescription)")
        }
    }

    /// Removes the installed WhiskyWine runtime.
    ///
    /// This deletes the Libraries folder containing Wine and DXVK.
    /// Existing bottles are not affected, but they will not be able
    /// to run programs until WhiskyWine is reinstalled.
    public static func uninstall() {
        do {
            try FileManager.default.removeItem(at: libraryFolder)
        } catch {
            logger.error("Failed to uninstall WhiskyWine: \(error.localizedDescription)")
        }
    }

    /// Returns the version of the installed WhiskyWine runtime.
    ///
    /// - Returns: The semantic version of the installed WhiskyWine,
    ///   or `nil` if WhiskyWine is not installed or the version
    ///   file cannot be read.
    public static func whiskyWineVersion() -> SemanticVersion? {
        whiskyWineInfo()?.version
    }

    /// Returns the full version record of the installed WhiskyWine runtime.
    ///
    /// - Returns: The decoded `WhiskyWineVersion` plist contents, or `nil` if the
    ///   version file cannot be read.
    public static func whiskyWineInfo() -> WhiskyWineVersion? {
        let versionPlist = libraryFolder
            .appending(path: "WhiskyWineVersion")
            .appendingPathExtension("plist")
        return whiskyWineInfo(at: versionPlist)
    }

    /// Returns the full version record from an arbitrary version plist.
    ///
    /// This is primarily used by tests and release tooling that need to inspect
    /// the bundled DXVK version without depending on a fixed install location.
    ///
    /// - Parameter versionPlist: The plist file to decode.
    /// - Returns: The decoded version record, or `nil` if decoding fails.
    static func whiskyWineInfo(at versionPlist: URL) -> WhiskyWineVersion? {
        do {
            let decoder = PropertyListDecoder()
            let data = try Data(contentsOf: versionPlist)
            return try decoder.decode(WhiskyWineVersion.self, from: data)
        } catch {
            logger.debug("WhiskyWine version not found: \(error.localizedDescription)")
            return nil
        }
    }

    /// Returns the bundled DXVK release string from the installed WhiskyWine runtime.
    ///
    /// - Returns: The bundled DXVK version string, or `nil` if the runtime does
    ///   not expose a DXVK version in its plist.
    public static func whiskyWineDXVKVersion() -> String? {
        whiskyWineInfo()?.dxvkVersion
    }
}
