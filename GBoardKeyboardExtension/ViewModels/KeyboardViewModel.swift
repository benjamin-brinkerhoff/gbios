import SwiftUI
import Combine

public enum ActiveDrawer {
    case none
    case clipboard
    case voiceDictation
    case aiWritingTools
    case textEditingPad
    case cameraOCR
    case emojiPalette
}

public enum KeyboardMode {
    case alphabetic
    case numbers
    case symbols
}

public final class KeyboardViewModel: ObservableObject {
    @Published public var activeDrawer: ActiveDrawer = .none
    @Published public var keyboardMode: KeyboardMode = .alphabetic
    @Published public var isShifted: Bool = false
    @Published public var isCapsLock: Bool = false
    @Published public var needsInputModeSwitchKey: Bool = false
    @Published public var contextBefore: String = ""
    @Published public var contextAfter: String = ""
    @Published public var activePopupKey: KeyModel?
    @Published public var activePopupVariants: [String] = []
    @Published public var calculatedMathResult: String?
    @Published public var isIncognito: Bool = false

    // Callbacks to UIInputViewController
    public var onInsertText: ((String) -> Void)?
    public var onDeleteBackward: (() -> Void)?
    public var onNextKeyboard: (() -> Void)?
    public var onDismissKeyboard: (() -> Void)?
    public var onAdjustCursor: ((Int) -> Void)?
    public var onReplaceRange: ((Int, String) -> Void)?

    private var lastShiftTap: Date = .distantPast
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .light)

    public init() {
        hapticGenerator.prepare()
    }

    public func updateContext(before: String?, after: String?) {
        self.contextBefore = before ?? ""
        self.contextAfter = after ?? ""

        // GboardWu Inline Calculator evaluation
        if KeyboardSettings.shared.enableInlineCalculator {
            self.calculatedMathResult = MathCalculator.shared.evaluateExpressionInText(contextBefore)
        } else {
            self.calculatedMathResult = nil
        }
    }

    public func handleKeyPress(_ key: KeyModel) {
        triggerHaptic()
        switch key.type {
        case .character(let char):
            insertText(isShifted ? char.uppercased() : char)
            if isShifted && !isCapsLock { isShifted = false }
        case .secondaryCharacter(let primary, _):
            insertText(isShifted ? primary.uppercased() : primary)
            if isShifted && !isCapsLock { isShifted = false }
        case .shift:
            handleShiftPress()
        case .backspace:
            onDeleteBackward?()
        case .spacebar:
            insertText(" ")
        case .returnKey:
            insertText("\n")
        case .symbolToggle:
            keyboardMode = (keyboardMode == .symbols) ? .alphabetic : .symbols
        case .numberToggle:
            keyboardMode = (keyboardMode == .numbers) ? .alphabetic : .numbers
        case .globe:
            onNextKeyboard?()
        case .emojiToggle:
            activeDrawer = (activeDrawer == .emojiPalette) ? .none : .emojiPalette
        case .toolbarToggle:
            activeDrawer = .none
        }
    }

    public func insertText(_ text: String) {
        onInsertText?(text)
    }

    public func handleShiftPress() {
        let now = Date()
        if now.timeIntervalSince(lastShiftTap) < 0.3 {
            isCapsLock.toggle()
            isShifted = isCapsLock
        } else {
            if isCapsLock {
                isCapsLock = false
                isShifted = false
            } else {
                isShifted.toggle()
            }
        }
        lastShiftTap = now
    }

    public func triggerHaptic() {
        guard KeyboardSettings.shared.enableHapticFeedback else { return }
        hapticGenerator.impactOccurred()
    }

    public func refreshClipboard() {
        guard !isIncognito else { return }
        if UIPasteboard.general.hasStrings, let text = UIPasteboard.general.string {
            ClipboardStore.shared.addClip(text: text)
        }
    }
}
