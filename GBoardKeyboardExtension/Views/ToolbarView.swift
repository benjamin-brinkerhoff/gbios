import SwiftUI

struct ToolbarView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @ObservedObject private var settings = KeyboardSettings.shared

    var theme: KeyboardTheme { settings.currentTheme }

    var body: some View {
        HStack(spacing: 0) {
            // Google G Home Button
            Button {
                viewModel.triggerHaptic()
                viewModel.dismissPopup()
                withAnimation(.easeInOut(duration: 0.15)) {
                    viewModel.activeDrawer = .none
                }
            } label: {
                Text("G")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: theme.accentColorHex))
                    .frame(width: 28, height: 28)
                    .background(Color(hex: theme.keyColorHex))
                    .clipShape(Circle())
            }
            .frame(maxWidth: .infinity)

            // Gboard Translate icon
            if settings.enableTranslateFeature {
                ToolbarButton(icon: "character.bubble.fill", isActive: viewModel.activeDrawer == .translate, theme: theme) {
                    toggleDrawer(.translate)
                }
                .frame(maxWidth: .infinity)
            }

            // Clipboard Manager icon
            ToolbarButton(icon: "doc.on.clipboard", isActive: viewModel.activeDrawer == .clipboard, theme: theme) {
                toggleDrawer(.clipboard)
            }
            .frame(maxWidth: .infinity)

            // Gemini Rambler Voice Dictation icon
            ToolbarButton(icon: "mic.fill", isActive: viewModel.activeDrawer == .voiceDictation, theme: theme) {
                toggleDrawer(.voiceDictation)
            }
            .frame(maxWidth: .infinity)

            // AI Writing Tools icon
            ToolbarButton(icon: "sparkles", isActive: viewModel.activeDrawer == .aiWritingTools, theme: theme) {
                toggleDrawer(.aiWritingTools)
            }
            .frame(maxWidth: .infinity)

            // Text Editing Pad icon
            ToolbarButton(icon: "arrow.up.and.down.and.arrow.left.and.right", isActive: viewModel.activeDrawer == .textEditingPad, theme: theme) {
                toggleDrawer(.textEditingPad)
            }
            .frame(maxWidth: .infinity)

            // Camera OCR Scan Text icon
            ToolbarButton(icon: "text.viewfinder", isActive: viewModel.activeDrawer == .cameraOCR, theme: theme) {
                toggleDrawer(.cameraOCR)
            }
            .frame(maxWidth: .infinity)

            // In-Keyboard Theme & Quick Settings button
            ToolbarButton(icon: "paintpalette.fill", isActive: viewModel.activeDrawer == .quickSettings, theme: theme) {
                toggleDrawer(.quickSettings)
            }
            .frame(maxWidth: .infinity)

            // Incognito Toggle
            Button {
                viewModel.isIncognito.toggle()
                viewModel.triggerHaptic()
            } label: {
                Image(systemName: viewModel.isIncognito ? "eyeglasses" : "eye")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(viewModel.isIncognito ? .orange : Color(hex: theme.textSecondaryHex))
                    .frame(width: 28, height: 28)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 4)
        .frame(height: 34)
    }

    private func toggleDrawer(_ drawer: ActiveDrawer) {
        viewModel.triggerHaptic()
        viewModel.dismissPopup()
        withAnimation(.easeInOut(duration: 0.18)) {
            viewModel.activeDrawer = (viewModel.activeDrawer == drawer) ? .none : drawer
        }
    }
}

struct ToolbarButton: View {
    let icon: String
    let isActive: Bool
    let theme: KeyboardTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isActive ? Color(hex: theme.accentColorHex) : Color(hex: theme.textPrimaryHex))
                .frame(width: 28, height: 28)
                .background(isActive ? Color(hex: theme.accentColorHex).opacity(0.18) : Color.clear)
                .cornerRadius(6)
        }
    }
}
