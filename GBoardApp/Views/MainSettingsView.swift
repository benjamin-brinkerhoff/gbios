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
                    Text("Tip: You can switch between Apple iOS UI and Gboard Pixel UI anytime.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section(header: Text("Keyboard Appearance & Layout Mode")) {
                    Toggle("Apple iOS Keyboard Layout Mode", isOn: $settings.useNativeIOSLayout)
                        .onChange(of: settings.useNativeIOSLayout) { isIOS in
                            settings.setNativeIOSMode(enabled: isIOS, isDark: true)
                        }
                    Text("When enabled, the keyboard looks identical to the native iOS keyboard (colors, clean predictive bar, 4-key bottom row) while retaining full Android-style popup keys on hold.")
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
                        Label("Theme & Keycaps", systemImage: "paintpalette")
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

                Section(header: Text("Popup Keys & Android Enhancements")) {
                    Toggle("Secondary Symbol Hints on Keys", isOn: $settings.showSecondarySymbols)
                    Toggle("Keypress Popups & Accent Menus", isOn: $settings.enableKeyPopups)
                    Toggle("Dedicated Top Number Row", isOn: $settings.showDedicatedNumberRow)
                    Toggle("Spacebar Cursor Trackpad", isOn: $settings.enableSpacebarCursorTrackpad)
                    Toggle("Inline Calculator Chip", isOn: $settings.enableInlineCalculator)
                    Toggle("Haptic Feedback on Tap", isOn: $settings.enableHapticFeedback)
                }

                Section(header: Text("About gbios")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.3.0 (Native iOS UI Mode + Gboard Popups)")
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
