import Foundation

public struct ClipboardItem: Identifiable, Codable, Equatable {
    public let id: UUID
    public let text: String
    public let timestamp: Date
    public var isPinned: Bool
    public let characterCount: Int

    public init(id: UUID = UUID(), text: String, timestamp: Date = Date(), isPinned: Bool = false) {
        self.id = id
        self.text = text
        self.timestamp = timestamp
        self.isPinned = isPinned
        self.characterCount = text.count
    }

    public var previewText: String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count > 100 {
            let index = trimmed.index(trimmed.startIndex, offsetBy: 100)
            return String(trimmed[..<index]) + "..."
        }
        return trimmed
    }

    public var formattedTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
