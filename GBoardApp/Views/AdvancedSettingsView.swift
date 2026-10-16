import UIKit
import SwiftUI

struct AdvancedSettingsView: View {
    @StateObject private var settings = KeyboardSettings.shared
    @State private var exportedJSON: String = ""
    @State private var showingExportAlert: Bool = false

    var body: some View {
        Form {
            Section(header: Text("Typing Experience")) {
                Toggle("Secondary Character Popup Hints", isOn: $settings.showSecondarySymbols)
                Toggle("Long-Press Accent Characters", isOn: $settings.enableLongPressAccents)
                Toggle("Keypress Preview Popups", isOn: $settings.enableKeyPopups)
                Toggle("Spacebar Cursor Trackpad Mode", isOn: $settings.enableSpacebarCursorTrackpad)
                Toggle("Inline Math Calculator Chip", isOn: $settings.enableInlineCalculator)
            }

            Section(header: Text("Feedback")) {
                Toggle("Haptic Feedback", isOn: $settings.enableHapticFeedback)
                Toggle("Sound on Keypress", isOn: $settings.enableKeyClickSound)
            }

            Section(header: Text("Backup & Restore (GboardWu Compatible)")) {
                Button("Export Settings as JSON") {
                    if let json = settings.exportConfigurationJSON() {
                        UIPasteboard.general.string = json
                        showingExportAlert = true
                    }
                }
            }
        }
        .alert("Configuration Copied", isPresented: $showingExportAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Settings JSON has been copied to your clipboard.")
        }
        .navigationTitle("Advanced Settings")
    }
}
