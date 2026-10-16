import SwiftUI

struct SetupInstructionsView: View {
    var body: some View {
        List {
            Section(header: Text("How to Enable gbios on iOS")) {
                StepRow(step: "1", title: "Open Settings", desc: "Go to Settings on your iPhone or iPad.")
                StepRow(step: "2", title: "General > Keyboard", desc: "Navigate to General, then select Keyboard > Keyboards.")
                StepRow(step: "3", title: "Add New Keyboard", desc: "Tap 'Add New Keyboard...' and select 'gbios'.")
                StepRow(step: "4", title: "Allow Full Access", desc: "Tap 'gbios' in your keyboard list and toggle 'Allow Full Access' ON to enable the Clipboard Manager, Voice Dictation, and Web Clipboard.")
            }
        }
        .navigationTitle("Setup Guide")
    }
}

struct StepRow: View {
    let step: String
    let title: String
    let desc: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text(step)
                .font(.headline)
                .frame(width: 28, height: 28)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(desc)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
