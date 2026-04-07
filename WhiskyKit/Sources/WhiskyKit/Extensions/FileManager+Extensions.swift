//
//  FileManager+Extensions.swift
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

extension FileManager {
    func replaceFiles(
        in destinationDirectory: URL, withContentsIn sourceDirectory: URL, makeOriginalCopy: Bool = false
    ) throws {
        let keys: [URLResourceKey] = [.isRegularFileKey]
        let enumerator = FileManager.default.enumerator(
            at: sourceDirectory,
            includingPropertiesForKeys: keys,
            options: [.skipsHiddenFiles]
        )

        let sourceRoot = sourceDirectory.path(percentEncoded: false)
        let sourcePrefix = sourceRoot.hasSuffix("/") ? sourceRoot : sourceRoot + "/"

        while let fileURL = enumerator?.nextObject() as? URL {
            guard fileURL.hasDirectoryPath == false else { continue }
            let filePath = fileURL.path(percentEncoded: false)
            let relativePath = filePath.hasPrefix(sourcePrefix) ? String(filePath.dropFirst(sourcePrefix.count)) : fileURL
                .lastPathComponent
            let destinationURL = destinationDirectory.appending(path: relativePath)
            try FileManager.default.createDirectory(
                at: destinationURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try FileManager.default.replaceFile(
                at: destinationURL,
                with: fileURL,
                makeOriginalCopy: makeOriginalCopy
            )
        }
    }

    func replaceDLLs(
        in destinationDirectory: URL, withContentsIn sourceDirectory: URL, makeOriginalCopy: Bool = false
    ) throws {
        let enumerator = FileManager.default.enumerator(
            at: sourceDirectory, includingPropertiesForKeys: [.isRegularFileKey]
        )

        while let fileURL = enumerator?.nextObject() as? URL {
            guard fileURL.pathExtension == "dll" else { continue }
            let originalURL = destinationDirectory.appending(path: fileURL.lastPathComponent)
            try FileManager.default.replaceFile(at: originalURL, with: fileURL, makeOriginalCopy: makeOriginalCopy)
        }
    }

    func replaceFile(at originalURL: URL, with replacementURL: URL, makeOriginalCopy: Bool = true) throws {
        try createDirectory(
            at: originalURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        if fileExists(atPath: originalURL.path(percentEncoded: false)) {
            if makeOriginalCopy {
                let copyURL = originalURL.appendingPathExtension("orig")

                if fileExists(atPath: copyURL.path(percentEncoded: false)) {
                    try FileManager.default.removeItem(at: copyURL)
                }

                try FileManager.default.moveItem(at: originalURL, to: copyURL)
            } else {
                try FileManager.default.removeItem(at: originalURL)
            }

            try FileManager.default.copyItem(at: replacementURL, to: originalURL)
        } else {
            try FileManager.default.copyItem(at: replacementURL, to: originalURL)
        }
    }
}
