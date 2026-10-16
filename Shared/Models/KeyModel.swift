import SwiftUI
import Foundation

public enum KeyType: Equatable {
    case character(String)
    case secondaryCharacter(primary: String, secondary: String)
    case shift
    case backspace
    case symbolToggle
    case numberToggle
    case spacebar
    case returnKey
    case globe
    case emojiToggle
    case toolbarToggle
}

public struct KeyModel: Identifiable, Equatable {
    public let id = UUID()
    public let primaryText: String
    public let secondaryText: String?
    public let alternateVariants: [String]
    public let type: KeyType
    public let widthMultiplier: CGFloat

    public init(
        primaryText: String,
        secondaryText: String? = nil,
        alternateVariants: [String] = [],
        type: KeyType,
        widthMultiplier: CGFloat = 1.0
    ) {
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.alternateVariants = alternateVariants
        self.type = type
        self.widthMultiplier = widthMultiplier
    }

    public static func defaultQwertyRows(showSecondary: Bool) -> [[KeyModel]] {
        let row1Data: [(String, String, [String])] = [
            ("q", "1", ["1", "q", "Q"]),
            ("w", "2", ["2", "w", "W"]),
            ("e", "3", ["3", "e", "é", "è", "ê", "ë", "ē"]),
            ("r", "4", ["4", "r", "R"]),
            ("t", "5", ["5", "t", "þ"]),
            ("y", "6", ["6", "y", "ÿ"]),
            ("u", "7", ["7", "u", "ú", "ù", "û", "ü", "ū"]),
            ("i", "8", ["8", "i", "í", "ì", "î", "ï", "ī"]),
            ("o", "9", ["9", "o", "ó", "ò", "ô", "ö", "õ", "œ", "ø", "ō"]),
            ("p", "0", ["0", "p", "P"])
        ]

        let row2Data: [(String, String, [String])] = [
            ("a", "@", ["@", "a", "á", "à", "â", "ä", "æ", "ã", "å", "ā"]),
            ("s", "#", ["#", "s", "ß", "$"]),
            ("d", "$", ["$", "d", "ð"]),
            ("f", "_", ["_", "f"]),
            ("g", "&", ["&", "g"]),
            ("h", "-", ["-", "h"]),
            ("j", "+", ["+", "j"]),
            ("k", "(", ["(", "k"]),
            ("l", ")", [")", "l"])
        ]

        let row3Data: [(String, String, [String])] = [
            ("z", "*", ["*", "z"]),
            ("x", "\"", ["\"", "x"]),
            ("c", "'", ["'", "c", "ç"]),
            ("v", ":", [":", "v"]),
            ("b", ";", [";", "b"]),
            ("n", "!", ["!", "n", "ñ"]),
            ("m", "?", ["?", "m"])
        ]

        let row1 = row1Data.map {
            KeyModel(
                primaryText: $0.0,
                secondaryText: showSecondary ? $0.1 : nil,
                alternateVariants: $0.2,
                type: .secondaryCharacter(primary: $0.0, secondary: $0.1)
            )
        }

        let row2 = row2Data.map {
            KeyModel(
                primaryText: $0.0,
                secondaryText: showSecondary ? $0.1 : nil,
                alternateVariants: $0.2,
                type: .secondaryCharacter(primary: $0.0, secondary: $0.1)
            )
        }

        var row3: [KeyModel] = [
            KeyModel(primaryText: "shift", type: .shift, widthMultiplier: 1.4)
        ]
        row3.append(contentsOf: row3Data.map {
            KeyModel(
                primaryText: $0.0,
                secondaryText: showSecondary ? $0.1 : nil,
                alternateVariants: $0.2,
                type: .secondaryCharacter(primary: $0.0, secondary: $0.1)
            )
        })
        row3.append(KeyModel(primaryText: "delete", type: .backspace, widthMultiplier: 1.4))

        return [row1, row2, row3]
    }

    public static func dedicatedNumberRow() -> [KeyModel] {
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"].map {
            KeyModel(primaryText: $0, type: .character($0))
        }
    }
}
