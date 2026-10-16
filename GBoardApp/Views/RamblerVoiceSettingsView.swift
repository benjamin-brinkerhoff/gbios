import SwiftUI

struct RamblerVoiceSettingsView: View {
    @StateObject private var settings = KeyboardSettings.shared

    var body: some View {
        Form {
            Section(header: Text("Gemini Rambler Voice Typing (Pixel 11)")) {
                Toggle("Enable Rambler Voice Dictation", isOn: $settings.enableRamblerVoice)

                if settings.enableRamblerVoice {
                    Toggle("Speech Cleanup (Remove 'um', 'uh', 'like')", isOn: $settings.ramblerRemoveFillerWords)
                    Toggle("Thought Completion & Auto-Punctuation", isOn: $settings.ramblerAutoPunctuation)
                }

                Text("Rambler analyzes your natural speech flow in real time, strips hesitations, and completes thoughts seamlessly.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section(header: Text("AI Writing Assistant (PixelBoard)")) {
                Toggle("Enable AI Writing Tools", isOn: $settings.enableAIWritingTools)
                Text("Adds the Writing Tools drawer above the keyboard: Proofread, Tone Switcher (Professional, Casual, Concise), and Smart Rewrite.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Voice & AI Tools")
    }
}
