//
//  DXVKConfigSection.swift
//  Whisky
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

import SwiftUI
import WhiskyKit

struct DXVKConfigSection: View {
    @ObservedObject var bottle: Bottle
    @Binding var isExpanded: Bool
    @Environment(\.openURL) private var openURL

    var body: some View {
        Section("config.title.dxvk", isExpanded: $isExpanded) {
            Picker("Direct3D backend", selection: $bottle.settings.d3dTranslationBackend) {
                ForEach(D3DTranslationBackend.allCases) { backend in
                    Text(backend.displayName).tag(backend)
                }
            }
            .help("DXVK remains the default. DXMT is experimental and requires a bundled DXMT runtime.")

            if bottle.settings.d3dTranslationBackend == .dxmtExperimental {
                Button(WhiskyWineInstaller.isDXMTInstalled() ? "Open DXMT Folder" : "Install DXMT") {
                    if WhiskyWineInstaller.isDXMTInstalled() {
                        WhiskyApp.openDXMTFolder()
                    } else if let url = URL(string: DistributionConfig.dxmtReleaseURL) {
                        openURL(url)
                    }
                }
                .buttonStyle(.borderedProminent)
            }

            Toggle(isOn: $bottle.settings.dxvk) {
                Text("config.dxvk")
            }
            .disabled(bottle.settings.d3dTranslationBackend == .dxmtExperimental)
            Toggle(isOn: $bottle.settings.dxvkAsync) {
                Text("config.dxvk.async")
            }
            .disabled(!bottle.settings.dxvk || bottle.settings.d3dTranslationBackend == .dxmtExperimental)
            Picker("config.dxvkHud", selection: $bottle.settings.dxvkHud) {
                Text("config.dxvkHud.full").tag(DXVKHUD.full)
                Text("config.dxvkHud.partial").tag(DXVKHUD.partial)
                Text("config.dxvkHud.fps").tag(DXVKHUD.fps)
                Text("config.dxvkHud.off").tag(DXVKHUD.off)
            }
            .disabled(!bottle.settings.dxvk || bottle.settings.d3dTranslationBackend == .dxmtExperimental)

            if bottle.settings.d3dTranslationBackend == .dxmtExperimental {
                Text(WhiskyWineInstaller.isDXMTInstalled()
                    ? "DXMT is experimental and intended for Apple Silicon and Tahoe."
                    : "DXMT is not installed. Install the DXMT runtime bundle before launching with this backend.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
