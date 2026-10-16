import SwiftUI

struct TextEditingPadView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    @StateObject private var settings = KeyboardSettings.shared

    var theme: KeyboardTheme { settings.currentTheme }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Text Editing")
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

            HStack(spacing: 12) {
                // Clipboard shortcut buttons
                VStack(spacing: 8) {
                    PadButton(title: "Select All", icon: "selection.pin.in.out", theme: theme) { }
                    PadButton(title: "Cut", icon: "scissors", theme: theme) { }
                    PadButton(title: "Copy", icon: "doc.on.doc", theme: theme) { }
                    PadButton(title: "Paste", icon: "doc.on.clipboard", theme: theme) {
                        viewModel.refreshClipboard()
                        if let first = ClipboardStore.shared.items.first {
                            viewModel.insertText(first.text)
                        }
                    }
                }

                Spacer()

                // Directional D-Pad
                VStack(spacing: 6) {
                    NavButton(icon: "chevron.up", theme: theme) { }
                    HStack(spacing: 14) {
                        NavButton(icon: "chevron.left", theme: theme) {
                            viewModel.onAdjustCursor?(-1)
                        }
                        NavButton(icon: "chevron.right", theme: theme) {
                            viewModel.onAdjustCursor?(1)
                        }
                    }
                    NavButton(icon: "chevron.down", theme: theme) { }
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 180)
        .background(Color(hex: theme.functionalKeyColorHex))
    }
}

struct PadButton: View {
    let title: String
    let icon: String
    let theme: KeyboardTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.system(size: 12, weight: .medium))
            }
            .frame(width: 100, height: 28)
            .background(Color(hex: theme.keyColorHex))
            .foregroundColor(Color(hex: theme.textPrimaryHex))
            .cornerRadius(6)
        }
    }
}

struct NavButton: View {
    let icon: String
    let theme: KeyboardTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .frame(width: 44, height: 36)
                .background(Color(hex: theme.keyColorHex))
                .foregroundColor(Color(hex: theme.textPrimaryHex))
                .cornerRadius(8)
        }
    }
}
