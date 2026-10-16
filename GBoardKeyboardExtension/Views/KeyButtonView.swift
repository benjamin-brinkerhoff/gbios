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
    var isLiquidGlass: Bool { settings.useNativeIOSLayout || theme.useFrostedGlass }

    var body: some View {
        ZStack {
            // Keycap background (iOS 26 Liquid Glass continuous squircle with subtle top specular rim)
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(isPressed || isPopupOpenForThisKey ? pressedBackground : keyBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            isLiquidGlass
                                ? Color.white.opacity(theme.isDark ? 0.11 : 0.35)
                                : Color.black.opacity(0.06),
                            lineWidth: 0.5
                        )
                )
                .shadow(
                    color: Color.black.opacity(isLiquidGlass ? 0.18 : 0.14),
                    radius: isLiquidGlass ? 0.5 : 0.8,
                    x: 0,
                    y: 1
                )

            // Secondary symbol hint in top-right corner (never shifts the centered primary letter!)
            if let sec = key.secondaryText, settings.showSecondarySymbols, viewModel.keyboardMode == .alphabetic {
                VStack {
                    HStack {
                        Spacer()
                        Text(sec)
                            .font(.system(size: 9.5, weight: .medium))
                            .foregroundColor(Color(hex: theme.textSecondaryHex))
                            .padding(.trailing, 3.5)
                            .padding(.top, 1.5)
                    }
                    Spacer()
                }
            }

            // Dead-center primary key label / icon (matching iOS 26 typography)
            primaryContent
                .foregroundColor(Color(hex: theme.textPrimaryHex))
        }
        .frame(height: 43)
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
                if settings.enableKeyPopups && isCharacterKey && (isPressed || isPopupOpenForThisKey) {
                    Text(currentPreviewChar)
                        .font(.system(size: 26, weight: .regular))
                        .foregroundColor(Color(hex: theme.textPrimaryHex))
                        .frame(width: 48, height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(isLiquidGlass ? Color(red: 0.32, green: 0.32, blue: 0.34) : Color(hex: theme.keyColorHex))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.white.opacity(0.22), lineWidth: 0.8)
                        )
                        .shadow(color: Color.black.opacity(0.32), radius: 5, x: 0, y: 2)
                        .offset(y: -49)
                        .allowsHitTesting(false)
                }
            },
            alignment: .top
        )
        .zIndex(isPopupOpenForThisKey || isPressed ? 999 : 1)
    }

    private var currentPreviewChar: String {
        if isPopupOpenForThisKey && !viewModel.activePopupVariants.isEmpty {
            let idx = viewModel.selectedVariantIndex
            if idx >= 0 && idx < viewModel.activePopupVariants.count {
                return viewModel.activePopupVariants[idx]
            }
        }
        return displayLabel
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

            if key.type == .backspace {
                viewModel.startContinuousBackspace()
                return
            }

            // Fire haptic & audio click immediately on touch-down for zero-latency iOS feel!
            viewModel.triggerTouchDownFeedback()

            if isCharacterKey && (!key.alternateVariants.isEmpty || key.secondaryText != nil) {
                let work = DispatchWorkItem {
                    longPressTriggered = true
                    viewModel.showLongPressPopup(for: key)
                }
                holdWorkItem = work
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.21, execute: work)
            }
        } else if longPressTriggered && isPopupOpenForThisKey {
            let count = viewModel.activePopupVariants.count
            if count > 1 {
                let stepWidth: CGFloat = 28.0
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
            if abs(value.translation.width) > 14 {
                let idx = viewModel.selectedVariantIndex
                if idx >= 0 && idx < viewModel.activePopupVariants.count {
                    let chosen = viewModel.activePopupVariants[idx]
                    viewModel.selectPopupVariant(chosen)
                }
            }
            return
        }

        // Haptic already fired on touch-down, so pass playFeedback: false
        viewModel.handleKeyPress(key, playFeedback: false)
    }

    @ViewBuilder
    private var primaryContent: some View {
        switch key.type {
        case .shift:
            Image(systemName: viewModel.isCapsLock ? "capslock.fill" : (viewModel.isShifted ? "shift.fill" : "shift"))
                .font(.system(size: 18, weight: .medium))
        case .backspace:
            Image(systemName: "delete.left")
                .font(.system(size: 18, weight: .medium))
        case .returnKey:
            Image(systemName: "return")
                .font(.system(size: 18, weight: .medium))
        case .spacebar:
            if settings.useNativeIOSLayout {
                // Exact match to IMG_1457_8c6c10.png: clean blank center with subtle "A" in bottom-right corner
                ZStack(alignment: .bottomTrailing) {
                    Color.clear
                    Text("A")
                        .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: theme.textSecondaryHex))
                        .padding(.trailing, 7)
                        .padding(.bottom, 4)
                }
            } else {
                HStack(spacing: 5) {
                    if settings.showGLogoOnSpacebar {
                        Text("G")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: theme.accentColorHex))
                    }
                    Text("English")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color(hex: theme.textSecondaryHex))
                }
            }
        case .globe:
            Image(systemName: "globe")
                .font(.system(size: 16))
        case .emojiToggle:
            Image(systemName: "face.smiling")
                .font(.system(size: 19))
        case .symbolToggle, .numberToggle, .alphabeticToggle:
            Text(key.primaryText)
                .font(.system(size: 15, weight: .regular))
        default:
            Text(displayLabel)
                .font(.system(
                    size: (viewModel.keyboardMode == .alphabetic && !viewModel.isShifted && !viewModel.isCapsLock) ? 24.5 : 22.0,
                    weight: .regular
                ))
                .offset(y: (viewModel.keyboardMode == .alphabetic && !viewModel.isShifted && !viewModel.isCapsLock) ? -1.0 : 0)
        }
    }

    private var displayLabel: String {
        if viewModel.keyboardMode == .alphabetic {
            return (viewModel.isShifted || viewModel.isCapsLock) ? key.primaryText.uppercased() : key.primaryText
        }
        return key.primaryText
    }

    private var pressedBackground: Color {
        if isLiquidGlass {
            return Color.white.opacity(theme.isDark ? 0.34 : 0.95)
        }
        return Color(hex: theme.accentColorHex).opacity(0.35)
    }

    private var keyBackground: Color {
        if isLiquidGlass {
            // In iOS 26 Liquid Glass, character keys and functional keys share the same uniform translucent glass tint
            return Color(hex: theme.keyColorHex)
        }
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
