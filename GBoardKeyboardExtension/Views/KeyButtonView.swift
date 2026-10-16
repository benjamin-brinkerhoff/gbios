import SwiftUI

struct KeyButtonView: View {
    let key: KeyModel
    @ObservedObject var viewModel: KeyboardViewModel
    @ObservedObject private var settings = KeyboardSettings.shared

    @State private var isPressed: Bool = false
    @State private var longPressTriggered: Bool = false
    @State private var holdWorkItem: DispatchWorkItem? = nil

    var theme: KeyboardTheme { settings.currentTheme }
    var cornerRadius: CGFloat { settings.keycapStyle.cornerRadius }
    var isPopupOpenForThisKey: Bool { viewModel.activePopupKeyId == key.id }

    var body: some View {
        ZStack {
            // Keycap background
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(isPressed || isPopupOpenForThisKey ? Color(hex: theme.accentColorHex).opacity(0.35) : keyBackground)
                .shadow(color: Color.black.opacity(0.14), radius: 0.8, x: 0, y: 1)

            // Keycap labels
            ZStack {
                // Secondary symbol hint in top-right corner (Android Gboard style)
                if let sec = key.secondaryText, settings.showSecondarySymbols, viewModel.keyboardMode == .alphabetic {
                    VStack {
                        HStack {
                            Spacer()
                            Text(sec)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(Color(hex: theme.textSecondaryHex))
                                .padding(.trailing, 4)
                                .padding(.top, 2)
                        }
                        Spacer()
                    }
                }

                // Centered primary label / icon
                primaryContent
                    .foregroundColor(Color(hex: theme.textPrimaryHex))
                    .padding(.top, (key.secondaryText != nil && settings.showSecondarySymbols && viewModel.keyboardMode == .alphabetic) ? 4 : 0)
            }
        }
        .frame(height: 42)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    handleDragChanged(value)
                }
                .onEnded { value in
                    handleDragEnded(value)
                }
        )
        .overlay(
            Group {
                if isPopupOpenForThisKey && !viewModel.activePopupVariants.isEmpty {
                    KeyPopupBubbleView(
                        variants: viewModel.activePopupVariants,
                        selectedIndex: viewModel.selectedVariantIndex,
                        theme: theme,
                        onSelect: { chosen in
                            viewModel.selectPopupVariant(chosen)
                        }
                    )
                    .offset(y: -48)
                    .zIndex(999)
                } else if isPressed && settings.enableKeyPopups && isCharacterKey {
                    // Single key tap preview bubble
                    Text(displayLabel)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(Color(hex: theme.textPrimaryHex))
                        .frame(width: 42, height: 46)
                        .background(Color(hex: theme.keyColorHex))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2)
                        .offset(y: -44)
                        .allowsHitTesting(false)
                }
            },
            alignment: .top
        )
        .zIndex(isPopupOpenForThisKey || isPressed ? 100 : 1)
    }

    private var isCharacterKey: Bool {
        switch key.type {
        case .character, .secondaryCharacter:
            return true
        default:
            return false
        }
    }

    private func handleDragChanged(_ value: DragGesture.Value) {
        if !isPressed {
            isPressed = true
            longPressTriggered = false

            // Backspace starts deleting immediately and repeats while held
            if key.type == .backspace {
                viewModel.startContinuousBackspace()
                return
            }

            // Schedule long-press popup for character keys with variants/secondary symbols
            if isCharacterKey && (!key.alternateVariants.isEmpty || key.secondaryText != nil) {
                let work = DispatchWorkItem {
                    longPressTriggered = true
                    viewModel.showLongPressPopup(for: key)
                }
                holdWorkItem = work
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.22, execute: work)
            }
        } else if longPressTriggered && isPopupOpenForThisKey {
            // Allow sliding left/right across popup variants while holding
            let count = viewModel.activePopupVariants.count
            if count > 1 {
                let stepWidth: CGFloat = 30.0
                let offsetSteps = Int(round(value.translation.width / stepWidth))
                let clamped = max(0, min(count - 1, offsetSteps))
                if clamped != viewModel.selectedVariantIndex {
                    viewModel.selectedVariantIndex = clamped
                    viewModel.triggerHaptic()
                }
            }
        }
    }

    private func handleDragEnded(_ value: DragGesture.Value) {
        holdWorkItem?.cancel()
        holdWorkItem = nil
        isPressed = false

        if key.type == .backspace {
            viewModel.stopContinuousBackspace()
            return
        }

        if longPressTriggered && isPopupOpenForThisKey {
            // If user dragged horizontally across variants, insert the highlighted variant on release.
            // If user held in place and lifted finger, keep the popup open so they can tap any popup button directly!
            if abs(value.translation.width) > 14 {
                let idx = viewModel.selectedVariantIndex
                if idx >= 0 && idx < viewModel.activePopupVariants.count {
                    let chosen = viewModel.activePopupVariants[idx]
                    viewModel.selectPopupVariant(chosen)
                }
            }
            return
        }

        // Standard tap
        viewModel.handleKeyPress(key)
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
            Image(systemName: "return")
                .font(.system(size: 16, weight: .semibold))
        case .spacebar:
            HStack(spacing: 5) {
                if settings.showGLogoOnSpacebar {
                    Text("G")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: theme.accentColorHex))
                }
                Text("English")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: theme.textSecondaryHex))
            }
        case .globe:
            Image(systemName: "globe")
                .font(.system(size: 15))
        case .emojiToggle:
            Image(systemName: "face.smiling")
                .font(.system(size: 16))
        case .symbolToggle, .numberToggle, .alphabeticToggle:
            Text(key.primaryText)
                .font(.system(size: 13, weight: .semibold))
        default:
            Text(displayLabel)
                .font(.system(size: 20, weight: .regular))
        }
    }

    private var displayLabel: String {
        if viewModel.keyboardMode == .alphabetic {
            return (viewModel.isShifted || viewModel.isCapsLock) ? key.primaryText.uppercased() : key.primaryText
        }
        return key.primaryText
    }

    private var keyBackground: Color {
        switch key.type {
        case .character, .secondaryCharacter, .spacebar:
            return Color(hex: theme.keyColorHex)
        case .returnKey:
            return Color(hex: theme.accentColorHex).opacity(0.85)
        default:
            return Color(hex: theme.functionalKeyColorHex)
        }
    }
}
