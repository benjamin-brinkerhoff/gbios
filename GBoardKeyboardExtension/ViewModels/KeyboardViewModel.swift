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
    case quickSettings
}

public enum KeyboardMode: Equatable {
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

    // Interactive Long-Press Popup State
    @Published public var activePopupKeyId: String? = nil
    @Published public var activePopupVariants: [String] = []
    @Published public var selectedVariantIndex: Int = 0

    // Predictions & Inline Calculator
    @Published public var suggestions: [String] = ["the", "I", "to"]
    @Published public var currentWordPrefix: String = ""
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
    private let mediumHapticGenerator = UIImpactFeedbackGenerator(style: .medium)

    // Continuous Backspace Timer
    private var backspaceDelayTimer: Timer?
    private var backspaceRepeatTimer: Timer?
    private var backspaceTickCount: Int = 0

    private let commonVocabulary: [String] = [
        "the", "to", "and", "of", "in", "is", "it", "for", "that", "you",
        "on", "with", "this", "have", "are", "be", "at", "or", "from", "had",
        "by", "not", "what", "all", "were", "we", "when", "your", "can", "said",
        "there", "use", "an", "each", "which", "she", "do", "how", "their", "if",
        "will", "up", "other", "about", "out", "many", "then", "them", "these", "so",
        "some", "her", "would", "make", "like", "him", "into", "time", "has", "look",
        "two", "more", "write", "go", "see", "number", "no", "way", "could", "people",
        "hello", "help", "here", "home", "happy", "thanks", "thank", "today", "tomorrow",
        "great", "good", "going", "getting", "gboard", "keyboard", "iphone", "awesome",
        "because", "before", "better", "between", "please", "pretty", "problem", "project"
    ]

    public init() {
        hapticGenerator.prepare()
        mediumHapticGenerator.prepare()
    }

    public func updateContext(before: String?, after: String?) {
        self.contextBefore = before ?? ""
        self.contextAfter = after ?? ""

        if KeyboardSettings.shared.enableInlineCalculator {
            self.calculatedMathResult = MathCalculator.shared.evaluateExpressionInText(contextBefore)
        } else {
            self.calculatedMathResult = nil
        }

        updateSuggestions(from: self.contextBefore)
    }

    private func updateSuggestions(from before: String) {
        let components = before.components(separatedBy: CharacterSet.alphanumerics.inverted)
        let lastToken = components.last ?? ""
        self.currentWordPrefix = lastToken

        guard !lastToken.isEmpty else {
            self.suggestions = ["I", "the", "to"]
            return
        }

        let lower = lastToken.lowercased()
        var matches = commonVocabulary.filter { $0.hasPrefix(lower) && $0 != lower }
        if isShifted || (lastToken.first?.isUppercase == true) {
            matches = matches.map { $0.prefix(1).uppercased() + $0.dropFirst() }
        }

        var result: [String] = [lastToken]
        for m in matches.prefix(2) {
            result.append(m)
        }
        while result.count < 3 {
            let defaults = ["the", "and", "to"]
            for d in defaults where !result.contains(d) && result.count < 3 {
                result.append(d)
            }
            break
        }
        self.suggestions = Array(result.prefix(3))
    }

    public func applySuggestion(_ word: String) {
        triggerHaptic()
        dismissPopup()
        if activeDrawer == .translate {
            translateInputBuffer.append(word + " ")
            retranslateActiveBuffer()
            return
        }
        if !currentWordPrefix.isEmpty {
            onReplaceRange?(currentWordPrefix.count, word + " ")
        } else {
            insertText(word + " ")
        }
    }

    // MARK: - Continuous Backspace Hold-to-Delete
    public func startContinuousBackspace() {
        stopContinuousBackspace()
        dismissPopup()
        triggerHaptic()
        performSingleBackspace()
        backspaceTickCount = 0

        backspaceDelayTimer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.backspaceRepeatTimer = Timer.scheduledTimer(withTimeInterval: 0.065, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.backspaceTickCount += 1
                self.performSingleBackspace()
                if self.backspaceTickCount > 15 {
                    self.performSingleBackspace()
                }
            }
        }
    }

    public func stopContinuousBackspace() {
        backspaceDelayTimer?.invalidate()
        backspaceDelayTimer = nil
        backspaceRepeatTimer?.invalidate()
        backspaceRepeatTimer = nil
        backspaceTickCount = 0
    }

    private func performSingleBackspace() {
        if activeDrawer == .translate && !translateInputBuffer.isEmpty {
            translateInputBuffer.removeLast()
            retranslateActiveBuffer()
        } else {
            onDeleteBackward?()
        }
    }

    // MARK: - Interactive Key Popup Management
    public func showLongPressPopup(for key: KeyModel) {
        guard KeyboardSettings.shared.enableKeyPopups else { return }
        var variants = key.alternateVariants
        if variants.isEmpty {
            if let sec = key.secondaryText {
                variants = [sec, key.primaryText]
            } else {
                variants = [key.primaryText]
            }
        }
        if isShifted || isCapsLock {
            variants = variants.map { $0.uppercased() }
        }
        mediumHapticGenerator.impactOccurred()
        activePopupKeyId = key.id
        activePopupVariants = variants
        selectedVariantIndex = 0
    }

    public func selectPopupVariant(_ variant: String) {
        triggerHaptic()
        routeTypedCharacter(variant)
        if isShifted && !isCapsLock {
            isShifted = false
        }
        dismissPopup()
    }

    public func dismissPopup() {
        activePopupKeyId = nil
        activePopupVariants = []
        selectedVariantIndex = 0
    }

    // MARK: - Key Press Handling
    public func handleKeyPress(_ key: KeyModel) {
        dismissPopup()
        triggerHaptic()
        switch key.type {
        case .character(let char):
            let output = (keyboardMode == .alphabetic && (isShifted || isCapsLock)) ? char.uppercased() : char
            routeTypedCharacter(output)
            if isShifted && !isCapsLock { isShifted = false }
        case .secondaryCharacter(let primary, _):
            let output = (isShifted || isCapsLock) ? primary.uppercased() : primary
            routeTypedCharacter(output)
            if isShifted && !isCapsLock { isShifted = false }
        case .shift:
            handleShiftPress()
        case .backspace:
            performSingleBackspace()
        case .spacebar:
            routeTypedCharacter(" ")
        case .returnKey:
            if activeDrawer == .translate && !translateInputBuffer.isEmpty {
                insertTranslatedBuffer()
            } else {
                insertText("\n")
            }
        case .numberToggle:
            keyboardMode = (keyboardMode == .numbers || keyboardMode == .symbols) ? .alphabetic : .numbers
        case .symbolToggle:
            keyboardMode = (keyboardMode == .symbols) ? .numbers : .symbols
        case .alphabeticToggle:
            keyboardMode = .alphabetic
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
