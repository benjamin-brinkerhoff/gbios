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

public final class SuggestionState: ObservableObject {
    @Published public var suggestions: [String] = ["I", "the", "to"]
    @Published public var calculatedMathResult: String? = nil
    @Published public var activePopupKeyId: String? = nil
    @Published public var activePopupVariants: [String] = []
    @Published public var selectedVariantIndex: Int = 0

    public init() {}
}

public final class KeyboardViewModel: ObservableObject {
    @Published public var activeDrawer: ActiveDrawer = .none
    @Published public var keyboardMode: KeyboardMode = .alphabetic
    @Published public var isShifted: Bool = false
    @Published public var isCapsLock: Bool = false
    @Published public var needsInputModeSwitchKey: Bool = false
    @Published public var isIncognito: Bool = false

    @Published public var translateInputBuffer: String = ""
    @Published public var translatedPreviewText: String = ""
    @Published public var isTranslating: Bool = false

    public let suggestionState = SuggestionState()

    public var contextBefore: String = ""
    public var contextAfter: String = ""
    public var currentWordPrefix: String = ""

    private var activeRolloverKey: KeyModel? = nil
    private var activeRolloverCommitClosure: (() -> Void)? = nil

    public var onPlayClick: (() -> Void)?
    public var onInsertText: ((String) -> Void)?
    public var onDeleteBackward: (() -> Void)?
    public var onNextKeyboard: (() -> Void)?
    public var onDismissKeyboard: (() -> Void)?
    public var onAdjustCursor: ((Int) -> Void)?
    public var onReplaceRange: ((Int, String) -> Void)?

    private var lastShiftTap: Date = .distantPast
    private let touchDownHaptic = UIImpactFeedbackGenerator(style: .light)
    private let popupHaptic = UIImpactFeedbackGenerator(style: .medium)

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
        "because", "before", "better", "between", "please", "pretty", "problem", "project",
        "world", "worlds", "world's", "work", "working", "would", "really", "right"
    ]

    public init() {
        touchDownHaptic.prepare()
        popupHaptic.prepare()
    }

    public func registerTouchDown(for key: KeyModel, commitClosure: @escaping () -> Void) {
        if let existingCommit = activeRolloverCommitClosure, activeRolloverKey?.id != key.id {
            existingCommit()
        }
        activeRolloverKey = key
        activeRolloverCommitClosure = commitClosure
        triggerTouchDownFeedback()
    }

    public func clearRollover(for key: KeyModel) {
        if activeRolloverKey?.id == key.id {
            activeRolloverKey = nil
            activeRolloverCommitClosure = nil
        }
    }

    public func triggerTouchDownFeedback() {
        onPlayClick?()
        if KeyboardSettings.shared.enableHapticFeedback {
            touchDownHaptic.impactOccurred(intensity: 0.7)
            touchDownHaptic.prepare()
        }
    }

    public func triggerHaptic() {
        guard KeyboardSettings.shared.enableHapticFeedback else { return }
        touchDownHaptic.impactOccurred(intensity: 0.65)
        touchDownHaptic.prepare()
    }

    public func triggerPopupHaptic() {
        guard KeyboardSettings.shared.enableHapticFeedback else { return }
        popupHaptic.impactOccurred(intensity: 0.85)
        popupHaptic.prepare()
    }

    public func updateContext(before: String?, after: String?) {
        let newBefore = before ?? ""
        self.contextBefore = newBefore
        self.contextAfter = after ?? ""

        if KeyboardSettings.shared.enableInlineCalculator &&
            (newBefore.contains("+") || newBefore.contains("-") || newBefore.contains("*") || newBefore.contains("/")) {
            let newCalc = MathCalculator.shared.evaluateExpressionInText(newBefore)
            if newCalc != suggestionState.calculatedMathResult {
                suggestionState.calculatedMathResult = newCalc
            }
        } else if suggestionState.calculatedMathResult != nil {
            suggestionState.calculatedMathResult = nil
        }

        updateSuggestions(from: newBefore)
    }

    private func updateSuggestions(from before: String) {
        let components = before.components(separatedBy: CharacterSet.alphanumerics.inverted)
        let lastToken = components.last ?? ""
        self.currentWordPrefix = lastToken

        let newSuggestions: [String]
        if lastToken.isEmpty {
            newSuggestions = ["I", "the", "to"]
        } else {
            let lower = lastToken.lowercased()
            var matches = commonVocabulary.filter { $0.hasPrefix(lower) && $0 != lower }
            if isShifted || (lastToken.first?.isUppercase == true) {
                matches = matches.map { $0.prefix(1).uppercased() + $0.dropFirst() }
            }
            var result: [String] = ["\"\(lastToken)\""]
            for m in matches.prefix(2) {
                result.append(m)
            }
            let fallbacks = [lastToken + "s", lastToken + "'s", "the", "and"]
            for f in fallbacks where result.count < 3 && !result.contains(f) {
                result.append(f)
            }
            newSuggestions = Array(result.prefix(3))
        }

        if newSuggestions != suggestionState.suggestions {
            suggestionState.suggestions = newSuggestions
        }
    }

    public func applySuggestion(_ word: String) {
        triggerTouchDownFeedback()
        dismissPopup()
        let cleanWord = word.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        if activeDrawer == .translate {
            translateInputBuffer.append(cleanWord + " ")
            retranslateActiveBuffer()
            return
        }
        if !currentWordPrefix.isEmpty {
            onReplaceRange?(currentWordPrefix.count, cleanWord + " ")
        } else {
            insertText(cleanWord + " ")
        }
    }

    public func startContinuousBackspace() {
        stopContinuousBackspace()
        dismissPopup()
        triggerTouchDownFeedback()
        performSingleBackspace()
        backspaceTickCount = 0

        backspaceDelayTimer = Timer.scheduledTimer(withTimeInterval: 0.30, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.backspaceRepeatTimer = Timer.scheduledTimer(withTimeInterval: 0.055, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.backspaceTickCount += 1
                self.performSingleBackspace()
                if self.backspaceTickCount > 14 {
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

    public func variantsForKey(_ key: KeyModel) -> [String] {
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
        return variants
    }

    public func showLongPressPopup(for key: KeyModel) {
        let variants = variantsForKey(key)
        triggerPopupHaptic()
        suggestionState.activePopupKeyId = key.id
        suggestionState.activePopupVariants = variants
        suggestionState.selectedVariantIndex = 0
    }

    public func updatePopupSelection(index: Int) {
        if suggestionState.selectedVariantIndex != index {
            suggestionState.selectedVariantIndex = index
            triggerHaptic()
        }
    }

    public func selectPopupVariant(_ variant: String) {
        routeTypedCharacter(variant)
        if isShifted && !isCapsLock {
            isShifted = false
        }
        dismissPopup()
    }

    public func dismissPopup() {
        if suggestionState.activePopupKeyId != nil {
            suggestionState.activePopupKeyId = nil
            suggestionState.activePopupVariants = []
            suggestionState.selectedVariantIndex = 0
        }
    }

    public func handleKeyPress(_ key: KeyModel, playFeedback: Bool = false) {
        dismissPopup()
        if playFeedback {
            triggerTouchDownFeedback()
        }
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

    public func refreshClipboard() {
        guard !isIncognito else { return }
        if UIPasteboard.general.hasStrings, let text = UIPasteboard.general.string {
            ClipboardStore.shared.addClip(text: text)
        }
    }
}
