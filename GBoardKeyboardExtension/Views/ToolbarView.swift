import SwiftUI

struct ToolbarView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @StateObject private var settings = KeyboardSettings.shared

    var theme: KeyboardTheme { settings.currentTheme }

    var body: some View {
        HStack(spacing: 14) {
            // Google G / Chevron Toggle
            Button {
                withAnimation(.spring()) {
                    viewModel.activeDrawer = .none
                }
            } label: {
                Text("G")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: theme.accentColorHex))
                    .frame(width: 32, height: 32)
                    .background(Color(hex: theme.keyColorHex))
                    .clipShape(Circle())
            }

            Spacer()

            // Clipboard Manager icon
            ToolbarButton(icon: "doc.on.clipboard", isActive: viewModel.activeDrawer == .clipboard, theme: theme) {
                toggleDrawer(.clipboard)
            }

            // Gemini Rambler Voice Dictation icon
            ToolbarButton(icon: "mic.fill", isActive: viewModel.activeDrawer == .voiceDictation, theme: theme) {
                toggleDrawer(.voiceDictation)
            }

            // AI Writing Tools icon
            ToolbarButton(icon: "sparkles", isActive: viewModel.activeDrawer == .aiWritingTools, theme: theme) {
                toggleDrawer(.aiWritingTools)
            }

            // Text Editing Pad icon
            ToolbarButton(icon: "arrow.up.and.down.and.arrow.left.and.right", isActive: viewModel.activeDrawer == .textEditingPad, theme: theme) {
                toggleDrawer(.textEditingPad)
            }

            // Camera OCR Scan Text icon
            ToolbarButton(icon: "text.viewfinder", isActive: viewModel.activeDrawer == .cameraOCR, theme: theme) {
                toggleDrawer(.cameraOCR)
            }

            // Incognito Toggle
            Button {
                viewModel.isIncognito.toggle()
                viewModel.triggerHaptic()
            } label: {
                Image(systemName: viewModel.isIncognito ? "eyeglasses" : "eye")
                    .font(.system(size: 15))
                    .foregroundColor(viewModel.isIncognito ? .orange : Color(hex: theme.textSecondaryHex))
            }
        }
        .padding(.horizontal, 10)
        .frame(height: 38)
    }

    private func toggleDrawer(_ drawer: ActiveDrawer) {
        viewModel.triggerHaptic()
        withAnimation(.easeInOut(duration: 0.2)) {
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
                .font(.system(size: 16))
                .foregroundColor(isActive ? Color(hex: theme.accentColorHex) : Color(hex: theme.textPrimaryHex))
                .frame(width: 30, height: 30)
                .background(isActive ? Color(hex: theme.accentColorHex).opacity(0.15) : Color.clear)
                .cornerRadius(6)
        }
    }
}
