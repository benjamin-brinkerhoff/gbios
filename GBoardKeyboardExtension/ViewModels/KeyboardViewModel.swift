import UIKit
import SwiftUI
import Combine

public enum ActiveDrawer {
    case none
    case translate
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

    // Gboard Translate state
    @Published public var translateInputBuffer: String = ""
    @Published public var translatedPreviewText: String = ""
    @Published public var isTranslating: Bool = false

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
            let output = isShifted ? char.uppercased() : char
            routeTypedCharacter(output)
            if isShifted && !isCapsLock { isShifted = false }
        case .secondaryCharacter(let primary, _):
            let output = isShifted ? primary.uppercased() : primary
            routeTypedCharacter(output)
            if isShifted && !isCapsLock { isShifted = false }
        case .shift:
            handleShiftPress()
        case .backspace:
            if activeDrawer == .translate && !translateInputBuffer.isEmpty {
                translateInputBuffer.removeLast()
                retranslateActiveBuffer()
            } else {
                onDeleteBackward?()
            }
        case .spacebar:
            routeTypedCharacter(" ")
        case .returnKey:
            if activeDrawer == .translate && !translateInputBuffer.isEmpty {
                insertTranslatedBuffer()
            } else {
                insertText("\n")
            }
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

    private func routeTypedCharacter(_ text: String) {
        if activeDrawer == .translate {
            translateInputBuffer.append(text)
            retranslateActiveBuffer()
        } else {
            insertText(text)
        }
    }

    public func retranslateActiveBuffer() {
        let query = translateInputBuffer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            translatedPreviewText = ""
            isTranslating = false
            return
        }
        isTranslating = true
        let source = KeyboardSettings.shared.translateSourceLang
        let target = KeyboardSettings.shared.translateTargetLang
        TranslationService.shared.translate(text: query, from: source, to: target) { [weak self] translated in
            guard let self = self else { return }
            self.isTranslating = false
            self.translatedPreviewText = translated
        }
    }

    public func insertTranslatedBuffer() {
        let finalOut = translatedPreviewText.isEmpty ? translateInputBuffer : translatedPreviewText
        guard !finalOut.isEmpty else { return }
        if !isIncognito {
            TranslationService.shared.saveToHistory(
                sourceText: translateInputBuffer,
                translatedText: finalOut,
                from: KeyboardSettings.shared.translateSourceLang,
                to: KeyboardSettings.shared.translateTargetLang
            )
        }
        insertText(finalOut + " ")
        clearTranslateBuffer()
    }

    public func translateCurrentDocumentContext() {
        let existing = contextBefore.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !existing.isEmpty else { return }
        isTranslating = true
        let source = KeyboardSettings.shared.translateSourceLang
        let target = KeyboardSettings.shared.translateTargetLang
        let replaceLen = contextBefore.count
        TranslationService.shared.translate(text: existing, from: source, to: target) { [weak self] translated in
            guard let self = self else { return }
            self.isTranslating = false
            if !self.isIncognito {
                TranslationService.shared.saveToHistory(
                    sourceText: existing,
                    translatedText: translated,
                    from: source,
                    to: target
                )
            }
            self.onReplaceRange?(replaceLen, translated)
        }
    }

    public func clearTranslateBuffer() {
        translateInputBuffer = ""
        translatedPreviewText = ""
        isTranslating = false
    }

    public func commitOrCloseTranslate() {
        if !translatedPreviewText.isEmpty {
            insertTranslatedBuffer()
        }
        activeDrawer = .none
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
