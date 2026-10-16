import SwiftUI

struct ClipboardManagerView: View {
    @StateObject private var clipboard = ClipboardStore.shared
    @StateObject private var webServer = WebClipboardServer.shared
    @StateObject private var settings = KeyboardSettings.shared
    @State private var searchQuery: String = ""

    var filteredClips: [ClipboardItem] {
        clipboard.search(query: searchQuery)
    }

    var body: some View {
        List {
            Section(header: Text("Web Clipboard (LAN Sync)")) {
                Toggle("Enable Web Clipboard Server", isOn: $settings.enableWebClipboard)
                    .onChange(of: settings.enableWebClipboard) { enabled in
                        if enabled {
                            webServer.start(port: UInt16(settings.webClipboardPort), pairingCode: settings.webClipboardPairingCode)
                        } else {
                            webServer.stop()
                        }
                    }

                if settings.enableWebClipboard {
                    HStack {
                        Text("Server Status")
                        Spacer()
                        Text(webServer.serverAddress)
                            .foregroundColor(webServer.isRunning ? .green : .red)
                            .font(.subheadline)
                    }
                    HStack {
                        Text("Pairing Code")
                        Spacer()
                        Text(settings.webClipboardPairingCode)
                            .font(.system(.body, design: .monospaced))
                            .bold()
                    }
                    Text("Open the URL on your PC or Mac browser over the same Wi-Fi to sync clipboard clips bidirectionally.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Section(header: Text("Saved Clips (\(filteredClips.count))")) {
                if filteredClips.isEmpty {
                    Text("No clips saved yet.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(filteredClips) { clip in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(clip.previewText)
                                    .font(.body)
                                Spacer()
                                if clip.isPinned {
                                    Image(systemName: "pin.fill")
                                        .foregroundColor(.orange)
                                }
                            }
                            Text("\(clip.characterCount) chars • \(clip.formattedTime)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                clipboard.togglePin(id: clip.id)
                            } label: {
                                Label(clip.isPinned ? "Unpin" : "Pin", systemImage: clip.isPinned ? "pin.slash" : "pin")
                            }
                            .tint(.orange)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                clipboard.deleteClip(id: clip.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: $searchQuery, prompt: "Search clipboard...")
        .navigationTitle("Clipboard Manager")
        .toolbar {
            Button("Clear Unpinned") {
                clipboard.clearUnpinned()
            }
        }
    }
}
