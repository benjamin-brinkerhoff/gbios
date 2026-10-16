import Foundation
import Combine

public final class KeyboardSettings: ObservableObject {
    public static let shared = KeyboardSettings()

    private let defaults: UserDefaults
    public static let appGroupIdentifier = "group.com.gbios.shared"

    @Published public var showSecondarySymbols: Bool {
        didSet { defaults.set(showSecondarySymbols, forKey: "showSecondarySymbols") }
    }
    @Published public var showDedicatedNumberRow: Bool {
        didSet { defaults.set(showDedicatedNumberRow, forKey: "showDedicatedNumberRow") }
    }
    @Published public var enableKeyPopups: Bool {
        didSet { defaults.set(enableKeyPopups, forKey: "enableKeyPopups") }
    }
    @Published public var enableLongPressAccents: Bool {
        didSet { defaults.set(enableLongPressAccents, forKey: "enableLongPressAccents") }
    }
    @Published public var enableSpacebarCursorTrackpad: Bool {
        didSet { defaults.set(enableSpacebarCursorTrackpad, forKey: "enableSpacebarCursorTrackpad") }
    }
    @Published public var enableInlineCalculator: Bool {
        didSet { defaults.set(enableInlineCalculator, forKey: "enableInlineCalculator") }
    }
    @Published public var enableHapticFeedback: Bool {
        didSet { defaults.set(enableHapticFeedback, forKey: "enableHapticFeedback") }
    }
    @Published public var enableKeyClickSound: Bool {
        didSet { defaults.set(enableKeyClickSound, forKey: "enableKeyClickSound") }
    }
    @Published public var showGLogoOnSpacebar: Bool {
        didSet { defaults.set(showGLogoOnSpacebar, forKey: "showGLogoOnSpacebar") }
    }
    @Published public var keycapStyleRaw: String {
        didSet { defaults.set(keycapStyleRaw, forKey: "keycapStyleRaw") }
    }
    @Published public var selectedThemeId: String {
        didSet { defaults.set(selectedThemeId, forKey: "selectedThemeId") }
    }
    @Published public var enableRamblerVoice: Bool {
        didSet { defaults.set(enableRamblerVoice, forKey: "enableRamblerVoice") }
    }
    @Published public var ramblerRemoveFillerWords: Bool {
        didSet { defaults.set(ramblerRemoveFillerWords, forKey: "ramblerRemoveFillerWords") }
    }
    @Published public var ramblerAutoPunctuation: Bool {
        didSet { defaults.set(ramblerAutoPunctuation, forKey: "ramblerAutoPunctuation") }
    }
    @Published public var enableAIWritingTools: Bool {
        didSet { defaults.set(enableAIWritingTools, forKey: "enableAIWritingTools") }
    }
    @Published public var enableTranslateFeature: Bool {
        didSet { defaults.set(enableTranslateFeature, forKey: "enableTranslateFeature") }
    }
    @Published public var translateSourceLang: String {
        didSet { defaults.set(translateSourceLang, forKey: "translateSourceLang") }
    }
    @Published public var translateTargetLang: String {
        didSet { defaults.set(translateTargetLang, forKey: "translateTargetLang") }
    }
    @Published public var translateLiveAsYouType: Bool {
        didSet { defaults.set(translateLiveAsYouType, forKey: "translateLiveAsYouType") }
    }
    @Published public var enableWebClipboard: Bool {
        didSet { defaults.set(enableWebClipboard, forKey: "enableWebClipboard") }
    }
    @Published public var webClipboardPort: Int {
        didSet { defaults.set(webClipboardPort, forKey: "webClipboardPort") }
    }
    @Published public var webClipboardPairingCode: String {
        didSet { defaults.set(webClipboardPairingCode, forKey: "webClipboardPairingCode") }
    }
    @Published public var clipboardRetentionHours: Int {
        didSet { defaults.set(clipboardRetentionHours, forKey: "clipboardRetentionHours") }
    }
    @Published public var maxClipboardItems: Int {
        didSet { defaults.set(maxClipboardItems, forKey: "maxClipboardItems") }
    }
    @Published public var oneHandedModeRaw: String {
        didSet { defaults.set(oneHandedModeRaw, forKey: "oneHandedModeRaw") }
    }
    @Published public var emojiSizeFactor: Double {
        didSet { defaults.set(emojiSizeFactor, forKey: "emojiSizeFactor") }
    }

    private init() {
        let store = UserDefaults(suiteName: KeyboardSettings.appGroupIdentifier) ?? UserDefaults.standard
        self.defaults = store

        self.showSecondarySymbols = store.object(forKey: "showSecondarySymbols") as? Bool ?? true
        self.showDedicatedNumberRow = store.object(forKey: "showDedicatedNumberRow") as? Bool ?? false
        self.enableKeyPopups = store.object(forKey: "enableKeyPopups") as? Bool ?? true
        self.enableLongPressAccents = store.object(forKey: "enableLongPressAccents") as? Bool ?? true
        self.enableSpacebarCursorTrackpad = store.object(forKey: "enableSpacebarCursorTrackpad") as? Bool ?? true
        self.enableInlineCalculator = store.object(forKey: "enableInlineCalculator") as? Bool ?? true
        self.enableHapticFeedback = store.object(forKey: "enableHapticFeedback") as? Bool ?? true
        self.enableKeyClickSound = store.object(forKey: "enableKeyClickSound") as? Bool ?? true
        self.showGLogoOnSpacebar = store.object(forKey: "showGLogoOnSpacebar") as? Bool ?? true
        self.keycapStyleRaw = store.string(forKey: "keycapStyleRaw") ?? KeycapStyle.belkaRounded.rawValue
        self.selectedThemeId = store.string(forKey: "selectedThemeId") ?? KeyboardTheme.material3Dynamic.id
        self.enableRamblerVoice = store.object(forKey: "enableRamblerVoice") as? Bool ?? true
        self.ramblerRemoveFillerWords = store.object(forKey: "ramblerRemoveFillerWords") as? Bool ?? true
        self.ramblerAutoPunctuation = store.object(forKey: "ramblerAutoPunctuation") as? Bool ?? true
        self.enableAIWritingTools = store.object(forKey: "enableAIWritingTools") as? Bool ?? true
        self.enableTranslateFeature = store.object(forKey: "enableTranslateFeature") as? Bool ?? true
        self.translateSourceLang = store.string(forKey: "translateSourceLang") ?? "auto"
        self.translateTargetLang = store.string(forKey: "translateTargetLang") ?? "es"
        self.translateLiveAsYouType = store.object(forKey: "translateLiveAsYouType") as? Bool ?? true
        self.enableWebClipboard = store.object(forKey: "enableWebClipboard") as? Bool ?? false
        self.webClipboardPort = store.object(forKey: "webClipboardPort") as? Int ?? 8088
        self.webClipboardPairingCode = store.string(forKey: "webClipboardPairingCode") ?? "4829"
        self.clipboardRetentionHours = store.object(forKey: "clipboardRetentionHours") as? Int ?? 168
        self.maxClipboardItems = store.object(forKey: "maxClipboardItems") as? Int ?? 100
        self.oneHandedModeRaw = store.string(forKey: "oneHandedModeRaw") ?? "none"
        self.emojiSizeFactor = store.object(forKey: "emojiSizeFactor") as? Double ?? 1.0
    }

    public var currentTheme: KeyboardTheme {
        KeyboardTheme.allThemes.first(where: { $0.id == selectedThemeId }) ?? .material3Dynamic
    }

    public var keycapStyle: KeycapStyle {
        KeycapStyle(rawValue: keycapStyleRaw) ?? .belkaRounded
    }

    public func swapTranslationLanguages() {
        guard translateSourceLang != "auto" else {
            translateSourceLang = translateTargetLang
            translateTargetLang = "en"
            return
        }
        let temp = translateSourceLang
        translateSourceLang = translateTargetLang
        translateTargetLang = temp
    }

    public func exportConfigurationJSON() -> String? {
        let dict: [String: Any] = [
            "showSecondarySymbols": showSecondarySymbols,
            "showDedicatedNumberRow": showDedicatedNumberRow,
            "enableKeyPopups": enableKeyPopups,
            "enableLongPressAccents": enableLongPressAccents,
            "enableSpacebarCursorTrackpad": enableSpacebarCursorTrackpad,
            "enableInlineCalculator": enableInlineCalculator,
            "enableHapticFeedback": enableHapticFeedback,
            "showGLogoOnSpacebar": showGLogoOnSpacebar,
            "keycapStyleRaw": keycapStyleRaw,
            "selectedThemeId": selectedThemeId,
            "enableRamblerVoice": enableRamblerVoice,
            "ramblerRemoveFillerWords": ramblerRemoveFillerWords,
            "enableTranslateFeature": enableTranslateFeature,
            "translateSourceLang": translateSourceLang,
            "translateTargetLang": translateTargetLang,
            "translateLiveAsYouType": translateLiveAsYouType,
            "webClipboardPort": webClipboardPort,
            "webClipboardPairingCode": webClipboardPairingCode,
            "exportedAt": ISO8601DateFormatter().string(from: Date())
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
