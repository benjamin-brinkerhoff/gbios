import SwiftUI

struct QuickSettingsDrawerView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @ObservedObject private var settings = KeyboardSettings.shared

    var theme: KeyboardTheme { settings.currentTheme }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("🎨 Themes & Quick Settings")
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

            // Theme Selector Strip
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(KeyboardTheme.allThemes) { item in
                        let isSelected = (settings.selectedThemeId == item.id)
                        Button {
                            viewModel.triggerHaptic()
                            settings.selectedThemeId = item.id
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

            // Quick Feature Toggles Grid
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    QuickToggleChip(
                        title: "Number Row",
                        isOn: settings.showDedicatedNumberRow,
                        theme: theme
                    ) {
                        settings.showDedicatedNumberRow.toggle()
                        viewModel.triggerHaptic()
                    }

                    QuickToggleChip(
                        title: "Symbol Hints",
                        isOn: settings.showSecondarySymbols,
                        theme: theme
                    ) {
                        settings.showSecondarySymbols.toggle()
                        viewModel.triggerHaptic()
                    }

                    QuickToggleChip(
                        title: "Key Popups",
                        isOn: settings.enableKeyPopups,
                        theme: theme
                    ) {
                        settings.enableKeyPopups.toggle()
                        viewModel.triggerHaptic()
                    }

                    QuickToggleChip(
                        title: "Belka Pill Keys",
                        isOn: settings.keycapStyle == .belkaRounded,
                        theme: theme
                    ) {
                        settings.keycapStyleRaw = (settings.keycapStyle == .belkaRounded)
                            ? KeycapStyle.classic.rawValue
                            : KeycapStyle.belkaRounded.rawValue
                        viewModel.triggerHaptic()
                    }

                    QuickToggleChip(
                        title: "G Logo",
                        isOn: settings.showGLogoOnSpacebar,
                        theme: theme
                    ) {
                        settings.showGLogoOnSpacebar.toggle()
                        viewModel.triggerHaptic()
                    }

                    QuickToggleChip(
                        title: "Haptics",
                        isOn: settings.enableHapticFeedback,
                        theme: theme
                    ) {
                        settings.enableHapticFeedback.toggle()
                        viewModel.triggerHaptic()
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

struct QuickToggleChip: View {
    let title: String
    let isOn: Bool
    let theme: KeyboardTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 12))
                    .foregroundColor(isOn ? Color(hex: theme.accentColorHex) : Color(hex: theme.textSecondaryHex))
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: theme.textPrimaryHex))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(hex: theme.keyColorHex))
            .cornerRadius(8)
        }
    }
}
