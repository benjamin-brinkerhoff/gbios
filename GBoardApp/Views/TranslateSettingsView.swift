import SwiftUI

struct TranslateSettingsView: View {
    @StateObject private var settings = KeyboardSettings.shared
    @StateObject private var translationService = TranslationService.shared
    @State private var sampleInput: String = "Hello, how are you?"
    @State private var sampleOutput: String = ""
    @State private var isTranslatingSample: Bool = false

    var body: some View {
        Form {
            Section(header: Text("Gboard In-Keyboard Translate")) {
                Toggle("Enable Gboard Translate Bar", isOn: $settings.enableTranslateFeature)
                Toggle("Live Translate as You Type", isOn: $settings.translateLiveAsYouType)

                Picker("Source Language", selection: $settings.translateSourceLang) {
                    ForEach(TranslationLanguage.sourceLanguages) { lang in
                        Text("\(lang.flag) \(lang.name)").tag(lang.code)
                    }
                }

                Picker("Target Language", selection: $settings.translateTargetLang) {
                    ForEach(TranslationLanguage.supportedLanguages) { lang in
                        Text("\(lang.flag) \(lang.name)").tag(lang.code)
                    }
                }

                Button {
                    settings.swapTranslationLanguages()
                    runSampleTranslation()
                } label: {
                    Label("Swap Source & Target Languages", systemImage: "arrow.left.arrow.right")
                }
            }

            Section(header: Text("Live Translation Tester")) {
                TextField("Enter text to translate...", text: $sampleInput)
                    .onChange(of: sampleInput) { _ in
                        runSampleTranslation()
                    }

                HStack {
                    Text("Translation:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    if isTranslatingSample {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }

                Text(sampleOutput.isEmpty ? "Tap Translate below to test" : sampleOutput)
                    .font(.headline)
                    .foregroundColor(.blue)

                Button("Translate Now") {
                    runSampleTranslation()
                }
            }

            Section(header: Text("Recent Translations (\(translationService.history.count))")) {
                if translationService.history.isEmpty {
                    Text("No recent translations yet.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(translationService.history) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.translatedText)
                                .font(.body)
                                .bold()
                            Text("\(item.sourceText) (\(item.sourceLangCode.uppercased()) → \(item.targetLangCode.uppercased()))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Button("Clear Translation History", role: .destructive) {
                        translationService.clearHistory()
                    }
                }
            }
        }
        .navigationTitle("Gboard Translate")
        .onAppear {
            runSampleTranslation()
        }
    }

    private func runSampleTranslation() {
        isTranslatingSample = true
        TranslationService.shared.translate(
            text: sampleInput,
            from: settings.translateSourceLang,
            to: settings.translateTargetLang
        ) { result in
            isTranslatingSample = false
            sampleOutput = result
        }
    }
}
