import SwiftUI

struct MainSettingsView: View {
    @ObservedObject private var settings = KeyboardSettings.shared
    @State private var testText: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Interactive Playground")) {
                    TextField("Tap here to test gbios keyboard...", text: $testText)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    Text("Tip: You can also change themes and toggle features directly inside the keyboard using the palette icon in the top toolbar.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section(header: Text("Core Features")) {
                    NavigationLink(destination: SetupInstructionsView()) {
                        Label("Setup & Enable Keyboard", systemImage: "keyboard")
                    }
                    NavigationLink(destination: TranslateSettingsView()) {
                        Label("Gboard Translate (13+ Languages)", systemImage: "character.bubble.fill")
                    }
                    NavigationLink(destination: ThemeGalleryView()) {
                        Label("Theme & Keycaps (Belka M3)", systemImage: "paintpalette")
                    }
                    NavigationLink(destination: ClipboardManagerView()) {
                        Label("Clipboard & Web Sync", systemImage: "doc.on.clipboard")
                    }
                    NavigationLink(destination: RamblerVoiceSettingsView()) {
                        Label("Gemini Rambler Voice & AI", systemImage: "waveform.and.mic")
                    }
                    NavigationLink(destination: AdvancedSettingsView()) {
                        Label("Advanced & Popups", systemImage: "gearshape.2")
                    }
                }

                Section(header: Text("Quick Android Gboard Toggles")) {
                    Toggle("Gboard In-Keyboard Translate Bar", isOn: $settings.enableTranslateFeature)
                    Toggle("Secondary Symbol Hints on Keys", isOn: $settings.showSecondarySymbols)
                    Toggle("Dedicated Number Row", isOn: $settings.showDedicatedNumberRow)
                    Toggle("Keypress Popups & Accents", isOn: $settings.enableKeyPopups)
                    Toggle("Spacebar Cursor Trackpad", isOn: $settings.enableSpacebarCursorTrackpad)
                    Toggle("Inline Calculator Chip", isOn: $settings.enableInlineCalculator)
                    Toggle("Haptic Feedback on Tap", isOn: $settings.enableHapticFeedback)
                }

                Section(header: Text("About gbios")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.2.0 (Full Screen + Interactive Popups)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("gbios")
            .onAppear {
                settings.reloadFromSharedStorage()
            }
        }
    }
}
