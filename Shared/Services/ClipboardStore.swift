import Foundation
import Combine

public final class ClipboardStore: ObservableObject {
    public static let shared = ClipboardStore()

    @Published public private(set) var items: [ClipboardItem] = []
    private let storageKey = "gbios_clipboard_items"
    private let defaults: UserDefaults

    public init() {
        let store = UserDefaults(suiteName: KeyboardSettings.appGroupIdentifier) ?? UserDefaults.standard
        self.defaults = store
        loadItems()
    }

    public func loadItems() {
        guard let data = defaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([ClipboardItem].self, from: data) else {
            self.items = []
            return
        }

        let retentionCutoff = Date().addingTimeInterval(-Double(KeyboardSettings.shared.clipboardRetentionHours * 3600))
        let filtered = decoded.filter { $0.isPinned || $0.timestamp > retentionCutoff }
        self.items = filtered
    }

    public func addClip(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if let first = items.first, first.text == trimmed {
            return
        }

        var updated = items.filter { $0.text != trimmed }
        let newClip = ClipboardItem(text: trimmed, timestamp: Date(), isPinned: false)
        updated.insert(newClip, at: 0)

        if updated.count > KeyboardSettings.shared.maxClipboardItems {
            var trimmedList: [ClipboardItem] = []
            var unpinnedCount = 0
            for it in updated {
                if it.isPinned {
                    trimmedList.append(it)
                } else if unpinnedCount < KeyboardSettings.shared.maxClipboardItems {
                    trimmedList.append(it)
                    unpinnedCount += 1
                }
            }
            updated = trimmedList
        }

        self.items = updated
        saveItems()
    }

    public func togglePin(id: UUID) {
        if let idx = items.firstIndex(where: { $0.id == id }) {
            items[idx].isPinned.toggle()
            saveItems()
        }
    }

    public func deleteClip(id: UUID) {
        items.removeAll(where: { $0.id == id })
        saveItems()
    }

    public func clearUnpinned() {
        items.removeAll(where: { !$0.isPinned })
        saveItems()
    }

    public func search(query: String) -> [ClipboardItem] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return items }
        return items.filter { $0.text.localizedCaseInsensitiveContains(query) }
    }

    private func saveItems() {
        if let data = try? JSONEncoder().encode(items) {
            defaults.set(data, forKey: storageKey)
        }
    }
}
