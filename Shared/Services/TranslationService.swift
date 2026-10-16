import Foundation
import Combine

public struct TranslationLanguage: Identifiable, Codable, Equatable, Hashable {
    public let code: String
    public let name: String
    public let flag: String
    public var id: String { code }

    public static let autoDetect = TranslationLanguage(code: "auto", name: "Detect Language", flag: "🌐")

    public static let supportedLanguages: [TranslationLanguage] = [
        TranslationLanguage(code: "en", name: "English", flag: "🇺🇸"),
        TranslationLanguage(code: "es", name: "Spanish", flag: "🇪🇸"),
        TranslationLanguage(code: "fr", name: "French", flag: "🇫🇷"),
        TranslationLanguage(code: "de", name: "German", flag: "🇩🇪"),
        TranslationLanguage(code: "it", name: "Italian", flag: "🇮🇹"),
        TranslationLanguage(code: "pt", name: "Portuguese", flag: "🇧🇷"),
        TranslationLanguage(code: "ja", name: "Japanese", flag: "🇯🇵"),
        TranslationLanguage(code: "ko", name: "Korean", flag: "🇰🇷"),
        TranslationLanguage(code: "zh-CN", name: "Chinese (Simplified)", flag: "🇨🇳"),
        TranslationLanguage(code: "zh-TW", name: "Chinese (Traditional)", flag: "🇹🇼"),
        TranslationLanguage(code: "ru", name: "Russian", flag: "🇷🇺"),
        TranslationLanguage(code: "ar", name: "Arabic", flag: "🇸🇦"),
        TranslationLanguage(code: "hi", name: "Hindi", flag: "🇮🇳")
    ]

    public static var sourceLanguages: [TranslationLanguage] {
        [autoDetect] + supportedLanguages
    }

    public static func language(for code: String) -> TranslationLanguage {
        if code == "auto" { return autoDetect }
        return supportedLanguages.first(where: { $0.code == code }) ?? supportedLanguages[0]
    }
}

public struct TranslationRecord: Identifiable, Codable, Equatable {
    public let id: UUID
    public let sourceText: String
    public let translatedText: String
    public let sourceLangCode: String
    public let targetLangCode: String
    public let timestamp: Date

    public init(
        id: UUID = UUID(),
        sourceText: String,
        translatedText: String,
        sourceLangCode: String,
        targetLangCode: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.sourceText = sourceText
        self.translatedText = translatedText
        self.sourceLangCode = sourceLangCode
        self.targetLangCode = targetLangCode
        self.timestamp = timestamp
    }
}

public final class TranslationService: ObservableObject {
    public static let shared = TranslationService()

    @Published public private(set) var history: [TranslationRecord] = []
    private let historyKey = "gbios_translation_history"
    private let defaults: UserDefaults

    private init() {
        let store = UserDefaults(suiteName: KeyboardSettings.appGroupIdentifier) ?? UserDefaults.standard
        self.defaults = store
        loadHistory()
    }

    public func loadHistory() {
        guard let data = defaults.data(forKey: historyKey),
              let decoded = try? JSONDecoder().decode([TranslationRecord].self, from: data) else {
            self.history = []
            return
        }
        self.history = decoded
    }

    public func saveToHistory(sourceText: String, translatedText: String, from sourceCode: String, to targetCode: String) {
        let trimmedSource = sourceText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTarget = translatedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSource.isEmpty, !trimmedTarget.isEmpty else { return }

        var updated = history.filter { !($0.sourceText == trimmedSource && $0.targetLangCode == targetCode) }
        let record = TranslationRecord(
            sourceText: trimmedSource,
            translatedText: trimmedTarget,
            sourceLangCode: sourceCode,
            targetLangCode: targetCode
        )
        updated.insert(record, at: 0)
        if updated.count > 50 {
            updated = Array(updated.prefix(50))
        }
        self.history = updated
        if let data = try? JSONEncoder().encode(updated) {
            defaults.set(data, forKey: historyKey)
        }
    }

    public func clearHistory() {
        history.removeAll()
        defaults.removeObject(forKey: historyKey)
    }

    public func translate(
        text: String,
        from sourceLang: String,
        to targetLang: String,
        completion: @escaping (String) -> Void
    ) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            DispatchQueue.main.async { completion("") }
            return
        }

        if sourceLang == targetLang {
            DispatchQueue.main.async { completion(trimmed) }
            return
        }

        let encodedText = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlStr = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=\(sourceLang)&tl=\(targetLang)&dt=t&q=\(encodedText)"

        guard let url = URL(string: urlStr) else {
            let fallback = offlineTranslate(text: trimmed, to: targetLang)
            DispatchQueue.main.async { completion(fallback) }
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 3.5
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)", forHTTPHeaderField: "User-Agent")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any],
               let sentences = json.first as? [[Any]] {
                var resultParts: [String] = []
                for item in sentences {
                    if let segment = item.first as? String {
                        resultParts.append(segment)
                    }
                }
                let combined = resultParts.joined()
                if !combined.isEmpty {
                    DispatchQueue.main.async {
                        completion(combined)
                    }
                    return
                }
            }

            let fallback = self.offlineTranslate(text: trimmed, to: targetLang)
            DispatchQueue.main.async {
                completion(fallback)
            }
        }.resume()
    }

    public func offlineTranslate(text: String, to targetLang: String) -> String {
        let lower = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        let phraseDictionary: [String: [String: String]] = [
            "hello": [
                "es": "hola", "fr": "bonjour", "de": "hallo", "it": "ciao",
                "pt": "olá", "ja": "こんにちは", "ko": "안녕하세요", "zh-CN": "你好",
                "zh-TW": "你好", "ru": "привет", "ar": "مرحبا", "hi": "नमस्ते"
            ],
            "how are you": [
                "es": "¿cómo estás?", "fr": "comment allez-vous ?", "de": "wie geht es dir?",
                "it": "come stai?", "pt": "como você está?", "ja": "お元気ですか？",
                "ko": "어떻게 지내세요?", "zh-CN": "你好吗？", "zh-TW": "你好嗎？",
                "ru": "как дела?", "ar": "كيف حالك؟", "hi": "आप कैसे हैं?"
            ],
            "thank you": [
                "es": "gracias", "fr": "merci", "de": "danke", "it": "grazie",
                "pt": "obrigado", "ja": "ありがとうございます", "ko": "감사합니다",
                "zh-CN": "谢谢", "zh-TW": "謝謝", "ru": "спасибо", "ar": "شكرا لك", "hi": "धन्यवाद"
            ],
            "good morning": [
                "es": "buenos días", "fr": "bonjour", "de": "guten morgen", "it": "buongiorno",
                "pt": "bom dia", "ja": "おはようございます", "ko": "좋은 아침입니다",
                "zh-CN": "早上好", "zh-TW": "早安", "ru": "доброе утро", "ar": "صباح الخير", "hi": "सुप्रभात"
            ],
            "good night": [
                "es": "buenas noches", "fr": "bonne nuit", "de": "gute nacht", "it": "buonanotte",
                "pt": "boa noite", "ja": "おやすみなさい", "ko": "안녕히 주무세요",
                "zh-CN": "晚安", "zh-TW": "晚安", "ru": "спокойной ночи", "ar": "تصبح على خير", "hi": "शुभ रात्रि"
            ],
            "yes": [
                "es": "sí", "fr": "oui", "de": "ja", "it": "sì", "pt": "sim",
                "ja": "はい", "ko": "네", "zh-CN": "是的", "ru": "да", "ar": "نعم", "hi": "हाँ"
            ],
            "no": [
                "es": "no", "fr": "non", "de": "nein", "it": "no", "pt": "não",
                "ja": "いいえ", "ko": "아니요", "zh-CN": "不是", "ru": "нет", "ar": "لا", "hi": "नहीं"
            ]
        ]

        if let match = phraseDictionary[lower]?[targetLang] {
            return text.first?.isUppercase == true ? match.prefix(1).uppercased() + match.dropFirst() : match
        }

        let words = lower.components(separatedBy: .whitespaces)
        var translatedWords: [String] = []
        var anyTranslated = false
        for w in words {
            let cleanWord = w.trimmingCharacters(in: .punctuationCharacters)
            if let mapped = phraseDictionary[cleanWord]?[targetLang] {
                translatedWords.append(mapped)
                anyTranslated = true
            } else {
                translatedWords.append(w)
            }
        }
        if anyTranslated {
            return translatedWords.joined(separator: " ")
        }
        return "[\(targetLang.uppercased())] \(text)"
    }
}
