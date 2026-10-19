import UIKit
import SwiftUI

final class KeyTouchReceivingUIView: UIView {
    var onTouchBegan: (() -> Void)?
    var onTouchMoved: ((CGFloat) -> Void)?
    var onTouchEnded: (() -> Void)?

    private var startX: CGFloat = 0
    private var isTrackingTouch: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isMultipleTouchEnabled = true
        isExclusiveTouch = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        startX = touch.location(in: self).x
        isTrackingTouch = true
        onTouchBegan?()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isTrackingTouch, let touch = touches.first else { return }
        let deltaX = touch.location(in: self).x - startX
        onTouchMoved?(deltaX)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isTrackingTouch else { return }
        isTrackingTouch = false
        onTouchEnded?()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isTrackingTouch else { return }
        isTrackingTouch = false
        onTouchEnded?()
    }
}

struct FastTouchOverlay: UIViewRepresentable {
    let onTouchBegan: () -> Void
    let onTouchMoved: (CGFloat) -> Void
    let onTouchEnded: () -> Void

    func makeUIView(context: Context) -> KeyTouchReceivingUIView {
        let view = KeyTouchReceivingUIView()
        view.onTouchBegan = onTouchBegan
        view.onTouchMoved = onTouchMoved
        view.onTouchEnded = onTouchEnded
        return view
    }

    func updateUIView(_ uiView: KeyTouchReceivingUIView, context: Context) {
        uiView.onTouchBegan = onTouchBegan
        uiView.onTouchMoved = onTouchMoved
        uiView.onTouchEnded = onTouchEnded
    }
}

struct KeyButtonView: View {
    let key: KeyModel
    @ObservedObject var viewModel: KeyboardViewModel
    var showBackground: Bool = true
    @ObservedObject private var settings = KeyboardSettings.shared

    @State private var isPressed: Bool = false
    @State private var isLongPressActive: Bool = false
    @State private var popupVariants: [String] = []
    @State private var selectedPopupIndex: Int = 0
    @State private var holdTimer: Timer? = nil
    @State private var alreadyCommittedByRollover: Bool = false

    var theme: KeyboardTheme { settings.currentTheme }
    var cornerRadius: CGFloat { settings.keycapStyle.cornerRadius }
    var isLiquidGlass: Bool { settings.useNativeIOSLayout || theme.useFrostedGlass }

    var body: some View {
        ZStack {
            if showBackground {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(isPressed || isLongPressActive ? pressedBackground : keyBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                isLiquidGlass
                                    ? Color.white.opacity(theme.isDark ? 0.11 : 0.35)
                                    : Color.black.opacity(0.06),
                                lineWidth: 0.5
                            )
                    )
            }

            if showBackground, let sec = key.secondaryText, settings.showSecondarySymbols, viewModel.keyboardMode == .alphabetic {
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

            primaryContent
                .foregroundColor(Color(hex: theme.textPrimaryHex))

            FastTouchOverlay(
                onTouchBegan: handleTouchBegan,
                onTouchMoved: handleTouchMoved,
                onTouchEnded: handleTouchEnded
            )
        }
        .frame(height: showBackground ? 43 : 32)
        .overlay(
            Group {
                if settings.enableKeyPopups && isCharacterKey && (isPressed || isLongPressActive) {
                    Text(currentPreviewChar)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(isLongPressActive ? .white : Color(hex: theme.textPrimaryHex))
                        .frame(width: 48, height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(
                                    isLongPressActive
                                        ? Color(hex: theme.accentColorHex)
                                        : (isLiquidGlass ? Color(red: 0.32, green: 0.32, blue: 0.34) : Color(hex: theme.keyColorHex))
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.white.opacity(0.25), lineWidth: 0.8)
                        )
                        .offset(y: -49)
                        .allowsHitTesting(false)
                }
            },
            alignment: .top
        )
        .zIndex(isLongPressActive || isPressed ? 999 : 1)
    }

    private var currentPreviewChar: String {
        if isLongPressActive && !popupVariants.isEmpty {
            let clamped = max(0, min(popupVariants.count - 1, selectedPopupIndex))
            return popupVariants[clamped]
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

    private func handleTouchBegan() {
        holdTimer?.invalidate()
        isPressed = true
        isLongPressActive = false
        alreadyCommittedByRollover = false

        if key.type == .backspace {
            viewModel.startContinuousBackspace()
            return
        }

        viewModel.registerTouchDown(for: key) {
            guard !alreadyCommittedByRollover else { return }
            alreadyCommittedByRollover = true
            holdTimer?.invalidate()
            holdTimer = nil
            isPressed = false
            if isLongPressActive && !popupVariants.isEmpty {
                let idx = max(0, min(popupVariants.count - 1, selectedPopupIndex))
                viewModel.selectPopupVariant(popupVariants[idx])
                isLongPressActive = false
            } else {
                viewModel.handleKeyPress(key, playFeedback: false)
            }
        }

        if isCharacterKey && (!key.alternateVariants.isEmpty || key.secondaryText != nil) {
            holdTimer = Timer.scheduledTimer(withTimeInterval: 0.19, repeats: false) { _ in
                guard isPressed && !alreadyCommittedByRollover else { return }
                let variants = viewModel.variantsForKey(key)
                popupVariants = variants
                selectedPopupIndex = 0
                isLongPressActive = true
                viewModel.showLongPressPopup(for: key)
            }
        }
    }

    private func handleTouchMoved(_ deltaX: CGFloat) {
        guard isLongPressActive, popupVariants.count > 1 else { return }
        let stepWidth: CGFloat = 26.0
        let offsetSteps = Int(round(deltaX / stepWidth))
        let clamped = max(0, min(popupVariants.count - 1, offsetSteps))
        if clamped != selectedPopupIndex {
            selectedPopupIndex = clamped
            viewModel.updatePopupSelection(index: clamped)
        }
    }

    private func handleTouchEnded() {
        holdTimer?.invalidate()
        holdTimer = nil
        isPressed = false
        viewModel.clearRollover(for: key)

        if key.type == .backspace {
            viewModel.stopContinuousBackspace()
            return
        }

        guard !alreadyCommittedByRollover else {
            isLongPressActive = false
            return
        }
        alreadyCommittedByRollover = true

        if isLongPressActive && !popupVariants.isEmpty {
            let idx = max(0, min(popupVariants.count - 1, selectedPopupIndex))
            let chosen = popupVariants[idx]
            isLongPressActive = false
            viewModel.selectPopupVariant(chosen)
            return
        }

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
