import SwiftUI

struct KeyButtonView: View {
    let key: KeyModel
    @ObservedObject var viewModel: KeyboardViewModel
    @StateObject private var settings = KeyboardSettings.shared

    @State private var isPressed: Bool = false
    @State private var longPressTriggered: Bool = false

    var theme: KeyboardTheme { settings.currentTheme }
    var cornerRadius: CGFloat { settings.keycapStyle.cornerRadius }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(isPressed ? Color(hex: theme.accentColorHex).opacity(0.3) : keyBackground)
                .shadow(color: Color.black.opacity(0.12), radius: 1, x: 0, y: 1)

            VStack(spacing: 1) {
                // Secondary symbol hint in top right (Android Gboard style)
                if let sec = key.secondaryText, settings.showSecondarySymbols {
                    HStack {
                        Spacer()
                        Text(sec)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: theme.textSecondaryHex))
                            .padding(.trailing, 4)
                            .padding(.top, 2)
                    }
                }

                // Primary key label
                primaryContent
                    .foregroundColor(Color(hex: theme.textPrimaryHex))
            }
        }
        .frame(height: 44)
        .overlay(
            Group {
                if isPressed && settings.enableKeyPopups && !key.alternateVariants.isEmpty {
                    KeyPopupBubbleView(primary: displayLabel, variants: key.alternateVariants, theme: theme)
                        .offset(y: -54)
                }
            }
        )
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                        viewModel.triggerHaptic()
                    }
                }
                .onEnded { _ in
                    isPressed = false
                    viewModel.handleKeyPress(key)
                }
        )
    }

    @ViewBuilder
    private var primaryContent: some View {
        switch key.type {
        case .shift:
            Image(systemName: viewModel.isCapsLock ? "capslock.fill" : (viewModel.isShifted ? "shift.fill" : "shift"))
                .font(.system(size: 16, weight: .semibold))
        case .backspace:
            Image(systemName: "delete.left.fill")
                .font(.system(size: 16))
        case .returnKey:
            Text("return")
                .font(.system(size: 14, weight: .medium))
        case .spacebar:
            HStack(spacing: 6) {
                if settings.showGLogoOnSpacebar {
                    Text("G")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: theme.accentColorHex))
                }
                Text("English")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(hex: theme.textSecondaryHex))
            }
        case .globe:
            Image(systemName: "globe")
                .font(.system(size: 16))
        case .emojiToggle:
            Image(systemName: "face.smiling")
                .font(.system(size: 16))
        case .symbolToggle, .numberToggle:
            Text(key.primaryText)
                .font(.system(size: 14, weight: .medium))
        default:
            Text(displayLabel)
                .font(.system(size: 20, weight: .regular))
        }
    }

    private var displayLabel: String {
        viewModel.isShifted ? key.primaryText.uppercased() : key.primaryText
    }

    private var keyBackground: Color {
        switch key.type {
        case .character, .secondaryCharacter, .spacebar:
            return Color(hex: theme.keyColorHex)
        default:
            return Color(hex: theme.functionalKeyColorHex)
        }
    }
}
