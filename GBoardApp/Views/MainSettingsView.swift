import SwiftUI

struct MainSettingsView: View {
    @StateObject private var settings = KeyboardSettings.shared
    @State private var testText: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Interactive Playground")) {
                    TextField("Tap here to test gbios keyboard...", text: $testText)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    Text("Tip: Ensure gbios is enabled in iOS Settings > General > Keyboard.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section(header: Text("Core Features")) {
                    NavigationLink(destination: SetupInstructionsView()) {
                        Label("Setup & Enable Keyboard", systemImage: "keyboard")
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
                        Text("1.0.0 (PixelBoard & GboardWu)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("gbios")
        }
    }
}
