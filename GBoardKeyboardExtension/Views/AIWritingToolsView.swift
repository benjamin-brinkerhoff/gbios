import SwiftUI

struct AIWritingToolsView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @StateObject private var settings = KeyboardSettings.shared

    var theme: KeyboardTheme { settings.currentTheme }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("✨ Gemini Writing Tools")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: theme.textPrimaryHex))
                Spacer()
                Button("Done") {
                    viewModel.activeDrawer = .none
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: theme.accentColorHex))
            }
            .padding(.horizontal, 10)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    AIActionChip(title: "Proofread", icon: "checkmark.bubble", theme: theme) {
                        applyProofread()
                    }
                    AIActionChip(title: "Professional", icon: "briefcase", theme: theme) {
                        applyTone("Professional")
                    }
                    AIActionChip(title: "Casual", icon: "face.smiling", theme: theme) {
                        applyTone("Casual")
                    }
                    AIActionChip(title: "Concise", icon: "arrow.down.right.and.arrow.up.left", theme: theme) {
                        applyTone("Concise")
                    }
                    AIActionChip(title: "Rephrase", icon: "arrow.triangle.2.circlepath", theme: theme) {
                        applyRephrase()
                    }
                }
                .padding(.horizontal, 10)
            }
        }
        .frame(height: 80)
        .background(Color(hex: theme.functionalKeyColorHex))
    }

    private func applyProofread() {
        viewModel.triggerHaptic()
        let text = viewModel.contextBefore
        guard !text.isEmpty else { return }
        let corrected = text.prefix(1).uppercased() + text.dropFirst()
        viewModel.onReplaceRange?(text.count, String(corrected))
    }

    private func applyTone(_ tone: String) {
        viewModel.triggerHaptic()
    }

    private func applyRephrase() {
        viewModel.triggerHaptic()
    }
}

struct AIActionChip: View {
    let title: String
    let icon: String
    let theme: KeyboardTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                Text(title)
                    .font(.system(size: 13, weight: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(hex: theme.keyColorHex))
            .foregroundColor(Color(hex: theme.textPrimaryHex))
            .cornerRadius(8)
        }
    }
}
