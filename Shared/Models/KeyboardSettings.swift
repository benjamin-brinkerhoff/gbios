import UIKit
import Foundation
import Combine

public final class KeyboardSettings: ObservableObject {
    public static let shared = KeyboardSettings()

    public static let appGroupIdentifier = "group.com.gbios.shared"
    public static let pasteboardSyncType = "com.gbios.settings.sync"
    private let storageKey = "gbios_settings_payload_v3"
    private var isReloading = false

    @Published public var useNativeIOSLayout: Bool = false { didSet { persistIfNeeded() } }
    @Published public var showSecondarySymbols: Bool = true { didSet { persistIfNeeded() } }
    @Published public var showDedicatedNumberRow: Bool = false { didSet { persistIfNeeded() } }
    @Published public var enableKeyPopups: Bool = true { didSet { persistIfNeeded() } }
    @Published public var enableLongPressAccents: Bool = true { didSet { persistIfNeeded() } }
    @Published public var enableSpacebarCursorTrackpad: Bool = true { didSet { persistIfNeeded() } }
    @Published public var enableInlineCalculator: Bool = true { didSet { persistIfNeeded() } }
    @Published public var enableHapticFeedback: Bool = true { didSet { persistIfNeeded() } }
    @Published public var enableKeyClickSound: Bool = true { didSet { persistIfNeeded() } }
    @Published public var showGLogoOnSpacebar: Bool = true { didSet { persistIfNeeded() } }
    @Published public var keycapStyleRaw: String = KeycapStyle.belkaRounded.rawValue { didSet { persistIfNeeded() } }
    @Published public var selectedThemeId: String = KeyboardTheme.material3Dynamic.id { didSet { persistIfNeeded() } }
    @Published public var enableRamblerVoice: Bool = true { didSet { persistIfNeeded() } }
    @Published public var ramblerRemoveFillerWords: Bool = true { didSet { persistIfNeeded() } }
    @Published public var ramblerAutoPunctuation: Bool = true { didSet { persistIfNeeded() } }
    @Published public var enableAIWritingTools: Bool = true { didSet { persistIfNeeded() } }
    @Published public var enableTranslateFeature: Bool = true { didSet { persistIfNeeded() } }
    @Published public var translateSourceLang: String = "auto" { didSet { persistIfNeeded() } }
    @Published public var translateTargetLang: String = "es" { didSet { persistIfNeeded() } }
    @Published public var translateLiveAsYouType: Bool = true { didSet { persistIfNeeded() } }
    @Published public var enableWebClipboard: Bool = false { didSet { persistIfNeeded() } }
    @Published public var webClipboardPort: Int = 8088 { didSet { persistIfNeeded() } }
    @Published public var webClipboardPairingCode: String = "4829" { didSet { persistIfNeeded() } }
    @Published public var clipboardRetentionHours: Int = 168 { didSet { persistIfNeeded() } }
    @Published public var maxClipboardItems: Int = 100 { didSet { persistIfNeeded() } }
    @Published public var oneHandedModeRaw: String = "none" { didSet { persistIfNeeded() } }
    @Published public var emojiSizeFactor: Double = 1.0 { didSet { persistIfNeeded() } }
    @Published public var lastUpdated: Double = 0

    private init() {
        reloadFromSharedStorage()
    }

    private var sharedFileURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: KeyboardSettings.appGroupIdentifier)?
            .appendingPathComponent("gbios_settings_v3.json")
    }

    private func persistIfNeeded() {
        guard !isReloading else { return }
        lastUpdated = Date().timeIntervalSince1970
        guard let data = encodeToData() else { return }

        UserDefaults.standard.set(data, forKey: storageKey)
        UserDefaults(suiteName: KeyboardSettings.appGroupIdentifier)?.set(data, forKey: storageKey)
        UserDefaults(suiteName: KeyboardSettings.appGroupIdentifier)?.synchronize()

        if let url = sharedFileURL {
            try? data.write(to: url, options: .atomic)
        }

        syncToPasteboardNonDestructively(data: data)
    }

    private func syncToPasteboardNonDestructively(data: Data) {
        let pb = UIPasteboard.general
        var currentItems = pb.items
        if currentItems.isEmpty {
            currentItems = [[KeyboardSettings.pasteboardSyncType: data]]
        } else {
            currentItems[0][KeyboardSettings.pasteboardSyncType] = data
        }
        pb.items = currentItems
    }

    public func reloadFromSharedStorage() {
        var candidates: [[String: Any]] = []

        if let d = UserDefaults.standard.data(forKey: storageKey),
           let dict = try? JSONSerialization.jsonObject(with: d) as? [String: Any] {
            candidates.append(dict)
        }
        if let d = UserDefaults(suiteName: KeyboardSettings.appGroupIdentifier)?.data(forKey: storageKey),
           let dict = try? JSONSerialization.jsonObject(with: d) as? [String: Any] {
            candidates.append(dict)
        }
        if let url = sharedFileURL,
           let d = try? Data(contentsOf: url),
           let dict = try? JSONSerialization.jsonObject(with: d) as? [String: Any] {
            candidates.append(dict)
        }
        if let d = UIPasteboard.general.data(forPasteboardType: KeyboardSettings.pasteboardSyncType),
           let dict = try? JSONSerialization.jsonObject(with: d) as? [String: Any] {
            candidates.append(dict)
        }

        guard let newest = candidates.max(by: {
            (($0["lastUpdated"] as? Double) ?? 0) < (($1["lastUpdated"] as? Double) ?? 0)
        }) else {
            return
        }

        let incomingTimestamp = (newest["lastUpdated"] as? Double) ?? 0
        guard incomingTimestamp >= self.lastUpdated else { return }

        applyDictionary(newest)
    }

    private func applyDictionary(_ dict: [String: Any]) {
        isReloading = true
        defer { isReloading = false }

        if let v = dict["useNativeIOSLayout"] as? Bool { useNativeIOSLayout = v }
        if let v = dict["showSecondarySymbols"] as? Bool { showSecondarySymbols = v }
        if let v = dict["showDedicatedNumberRow"] as? Bool { showDedicatedNumberRow = v }
        if let v = dict["enableKeyPopups"] as? Bool { enableKeyPopups = v }
        if let v = dict["enableLongPressAccents"] as? Bool { enableLongPressAccents = v }
        if let v = dict["enableSpacebarCursorTrackpad"] as? Bool { enableSpacebarCursorTrackpad = v }
        if let v = dict["enableInlineCalculator"] as? Bool { enableInlineCalculator = v }
        if let v = dict["enableHapticFeedback"] as? Bool { enableHapticFeedback = v }
        if let v = dict["enableKeyClickSound"] as? Bool { enableKeyClickSound = v }
        if let v = dict["showGLogoOnSpacebar"] as? Bool { showGLogoOnSpacebar = v }
        if let v = dict["keycapStyleRaw"] as? String { keycapStyleRaw = v }
        if let v = dict["selectedThemeId"] as? String { selectedThemeId = v }
        if let v = dict["enableRamblerVoice"] as? Bool { enableRamblerVoice = v }
        if let v = dict["ramblerRemoveFillerWords"] as? Bool { ramblerRemoveFillerWords = v }
        if let v = dict["ramblerAutoPunctuation"] as? Bool { ramblerAutoPunctuation = v }
        if let v = dict["enableAIWritingTools"] as? Bool { enableAIWritingTools = v }
        if let v = dict["enableTranslateFeature"] as? Bool { enableTranslateFeature = v }
        if let v = dict["translateSourceLang"] as? String { translateSourceLang = v }
        if let v = dict["translateTargetLang"] as? String { translateTargetLang = v }
        if let v = dict["translateLiveAsYouType"] as? Bool { translateLiveAsYouType = v }
        if let v = dict["enableWebClipboard"] as? Bool { enableWebClipboard = v }
        if let v = dict["webClipboardPort"] as? Int { webClipboardPort = v }
        if let v = dict["webClipboardPairingCode"] as? String { webClipboardPairingCode = v }
        if let v = dict["clipboardRetentionHours"] as? Int { clipboardRetentionHours = v }
        if let v = dict["maxClipboardItems"] as? Int { maxClipboardItems = v }
        if let v = dict["oneHandedModeRaw"] as? String { oneHandedModeRaw = v }
        if let v = dict["emojiSizeFactor"] as? Double { emojiSizeFactor = v }
        if let v = dict["lastUpdated"] as? Double { lastUpdated = v }
    }

    private func encodeToData() -> Data? {
        let dict: [String: Any] = [
            "useNativeIOSLayout": useNativeIOSLayout,
            "showSecondarySymbols": showSecondarySymbols,
            "showDedicatedNumberRow": showDedicatedNumberRow,
            "enableKeyPopups": enableKeyPopups,
            "enableLongPressAccents": enableLongPressAccents,
            "enableSpacebarCursorTrackpad": enableSpacebarCursorTrackpad,
            "enableInlineCalculator": enableInlineCalculator,
            "enableHapticFeedback": enableHapticFeedback,
            "enableKeyClickSound": enableKeyClickSound,
            "showGLogoOnSpacebar": showGLogoOnSpacebar,
            "keycapStyleRaw": keycapStyleRaw,
            "selectedThemeId": selectedThemeId,
            "enableRamblerVoice": enableRamblerVoice,
            "ramblerRemoveFillerWords": ramblerRemoveFillerWords,
            "ramblerAutoPunctuation": ramblerAutoPunctuation,
            "enableAIWritingTools": enableAIWritingTools,
            "enableTranslateFeature": enableTranslateFeature,
            "translateSourceLang": translateSourceLang,
            "translateTargetLang": translateTargetLang,
            "translateLiveAsYouType": translateLiveAsYouType,
            "enableWebClipboard": enableWebClipboard,
            "webClipboardPort": webClipboardPort,
            "webClipboardPairingCode": webClipboardPairingCode,
            "clipboardRetentionHours": clipboardRetentionHours,
            "maxClipboardItems": maxClipboardItems,
            "oneHandedModeRaw": oneHandedModeRaw,
            "emojiSizeFactor": emojiSizeFactor,
            "lastUpdated": lastUpdated
        ]
        return try? JSONSerialization.data(withJSONObject: dict, options: [])
    }

    public var currentTheme: KeyboardTheme {
        if useNativeIOSLayout && selectedThemeId != KeyboardTheme.iosNativeDark.id && selectedThemeId != KeyboardTheme.iosNativeLight.id {
            return .iosNativeDark
        }
        return KeyboardTheme.allThemes.first(where: { $0.id == selectedThemeId }) ?? .material3Dynamic
    }

    public var keycapStyle: KeycapStyle {
        if useNativeIOSLayout {
            return .classic
        }
        return KeycapStyle(rawValue: keycapStyleRaw) ?? .belkaRounded
    }

    public func setNativeIOSMode(enabled: Bool, isDark: Bool = true) {
        useNativeIOSLayout = enabled
        if enabled {
            selectedThemeId = isDark ? KeyboardTheme.iosNativeDark.id : KeyboardTheme.iosNativeLight.id
            keycapStyleRaw = KeycapStyle.classic.rawValue
            showGLogoOnSpacebar = false
        }
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
        guard let data = encodeToData(),
              let obj = try? JSONSerialization.jsonObject(with: data),
              let pretty = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted) else {
            return nil
        }
        return String(data: pretty, encoding: .utf8)
    }

}
