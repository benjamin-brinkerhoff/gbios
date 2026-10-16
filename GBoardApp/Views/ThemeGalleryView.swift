import SwiftUI

struct ThemeGalleryView: View {
    @StateObject private var settings = KeyboardSettings.shared

    var body: some View {
        Form {
            Section(header: Text("Keycap Shape (Material 3 Belka UI)")) {
                Picker("Key Style", selection: $settings.keycapStyleRaw) {
                    ForEach(KeycapStyle.allCases, id: \.rawValue) { style in
                        Text(style.rawValue).tag(style.rawValue)
                    }
                }
                .pickerStyle(.segmented)

                Toggle("Google 'G' Logo on Spacebar", isOn: $settings.showGLogoOnSpacebar)
            }

            Section(header: Text("Color Schemes")) {
                ForEach(KeyboardTheme.allThemes) { theme in
                    HStack {
                        Circle()
                            .fill(Color(hex: theme.accentColorHex))
                            .frame(width: 24, height: 24)

                        VStack(alignment: .leading) {
                            Text(theme.name)
                                .font(.headline)
                            Text(theme.isDark ? "Dark theme" : "Light theme")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if settings.selectedThemeId == theme.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        settings.selectedThemeId = theme.id
                    }
                }
            }
        }
        .navigationTitle("Themes & Keycaps")
    }
}
