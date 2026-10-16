import SwiftUI

struct QuickSettingsDrawerView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @ObservedObject private var settings = KeyboardSettings.shared

    var theme: KeyboardTheme { settings.currentTheme }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("🎨 Themes & Layout Mode")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: theme.textPrimaryHex))
                Spacer()
                Button("Done") {
                    viewModel.activeDrawer = .none
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: theme.accentColorHex))
            }
            .padding(.horizontal, 10)
            .padding(.top, 4)

            // Layout Mode Selector: iOS Native UI vs Gboard Android UI
            HStack(spacing: 8) {
                Button {
                    viewModel.triggerHaptic()
                    settings.setNativeIOSMode(enabled: true, isDark: true)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: settings.useNativeIOSLayout ? "checkmark.circle.fill" : "apple.logo")
                        Text("iOS Native UI")
                            .font(.system(size: 12, weight: settings.useNativeIOSLayout ? .bold : .medium))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(settings.useNativeIOSLayout ? Color(hex: theme.accentColorHex) : Color(hex: theme.keyColorHex))
                    .foregroundColor(settings.useNativeIOSLayout ? .white : Color(hex: theme.textPrimaryHex))
                    .cornerRadius(8)
                }

                Button {
                    viewModel.triggerHaptic()
                    settings.useNativeIOSLayout = false
                    settings.selectedThemeId = KeyboardTheme.material3Dynamic.id
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: !settings.useNativeIOSLayout ? "checkmark.circle.fill" : "g.circle")
                        Text("Gboard Pixel UI")
                            .font(.system(size: 12, weight: !settings.useNativeIOSLayout ? .bold : .medium))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(!settings.useNativeIOSLayout ? Color(hex: theme.accentColorHex) : Color(hex: theme.keyColorHex))
                    .foregroundColor(!settings.useNativeIOSLayout ? .white : Color(hex: theme.textPrimaryHex))
                    .cornerRadius(8)
                }

                Spacer()
            }
            .padding(.horizontal, 10)

            // Theme Selector Strip
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(KeyboardTheme.allThemes) { item in
                        let isSelected = (settings.selectedThemeId == item.id)
                        Button {
                            viewModel.triggerHaptic()
                            settings.selectedThemeId = item.id
                            if item.id == KeyboardTheme.iosNativeDark.id || item.id == KeyboardTheme.iosNativeLight.id {
                                settings.useNativeIOSLayout = true
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color(hex: item.accentColorHex))
                                    .frame(width: 14, height: 14)
                                Text(item.name)
                                    .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                                    .foregroundColor(Color(hex: item.textPrimaryHex))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(hex: item.keyColorHex))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isSelected ? Color(hex: theme.accentColorHex) : Color.clear, lineWidth: 2)
                            )
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
            Spacer(minLength: 2)
        }
        .frame(height: 115)
        .background(Color(hex: theme.functionalKeyColorHex))
    }
}
