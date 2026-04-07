//
//  D3DTranslationBackend.swift
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

/// Selects the Direct3D translation backend used for bottle launches.
///
/// DXVK remains the default and broadly compatible path. DXMT is exposed as an
/// experimental Apple Silicon/Tahoe-oriented backend for users who want to try
/// the Metal-based renderer on supported setups.
public enum D3DTranslationBackend: String, Codable, CaseIterable, Sendable, Identifiable {
    case dxvk
    case dxmtExperimental = "dxmt"

    public var id: String { rawValue }

    /// User-facing display name for configuration menus.
    public var displayName: String {
        switch self {
        case .dxvk:
            "DXVK"
        case .dxmtExperimental:
            "DXMT (Experimental)"
        }
    }
}
