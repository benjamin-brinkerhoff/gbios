import SwiftUI
import Foundation

public enum KeyType: Equatable {
    case character(String)
    case secondaryCharacter(primary: String, secondary: String)
    case shift
    case backspace
    case symbolToggle
    case numberToggle
    case alphabeticToggle
    case spacebar
    case returnKey
    case globe
    case emojiToggle
    case toolbarToggle
}

public struct KeyModel: Identifiable, Equatable {
    public let id: String
    public let primaryText: String
    public let secondaryText: String?
    public let alternateVariants: [String]
    public let type: KeyType
    public let widthMultiplier: CGFloat

    public init(
        id: String? = nil,
        primaryText: String,
        secondaryText: String? = nil,
        alternateVariants: [String] = [],
        type: KeyType,
        widthMultiplier: CGFloat = 1.0
    ) {
        self.id = id ?? "\(primaryText)_\(secondaryText ?? "")"
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.alternateVariants = alternateVariants
        self.type = type
        self.widthMultiplier = widthMultiplier
    }

    public static let cachedQwertyWithSecondary: [[KeyModel]] = buildQwertyRows(showSecondary: true)
    public static let cachedQwertyWithoutSecondary: [[KeyModel]] = buildQwertyRows(showSecondary: false)
    public static let cachedNumberRows: [[KeyModel]] = buildNumberAndPunctuationRows()
    public static let cachedDedicatedNumberRow: [KeyModel] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"].map {
        KeyModel(id: "numrow_\($0)", primaryText: $0, type: .character($0))
    }

    public static func defaultQwertyRows(showSecondary: Bool) -> [[KeyModel]] {
        showSecondary ? cachedQwertyWithSecondary : cachedQwertyWithoutSecondary
    }

    public static func numberAndPunctuationRows() -> [[KeyModel]] {
        cachedNumberRows
    }

    public static func dedicatedNumberRow() -> [KeyModel] {
        cachedDedicatedNumberRow
    }

    private static func buildQwertyRows(showSecondary: Bool) -> [[KeyModel]] {
        let row1Data: [(String, String, [String])] = [
            ("q", "1", ["1", "q"]),
            ("w", "2", ["2", "w"]),
            ("e", "3", ["3", "é", "è", "ê", "ë", "ē", "ė", "ę", "e"]),
            ("r", "4", ["4", "ř", "ŕ", "r"]),
            ("t", "5", ["5", "þ", "ť", "ț", "t"]),
            ("y", "6", ["6", "ý", "ÿ", "y"]),
            ("u", "7", ["7", "ú", "ù", "û", "ü", "ū", "ů", "ų", "u"]),
            ("i", "8", ["8", "í", "ì", "î", "ï", "ī", "į", "ı", "i"]),
            ("o", "9", ["9", "ó", "ò", "ô", "ö", "õ", "ø", "œ", "ō", "o"]),
            ("p", "0", ["0", "p"])
        ]

        let row2Data: [(String, String, [String])] = [
            ("a", "@", ["@", "á", "à", "â", "ä", "æ", "ã", "å", "ā", "ą", "a"]),
            ("s", "#", ["#", "ß", "ś", "š", "ş", "s"]),
            ("d", "$", ["$", "ð", "ď", "đ", "d"]),
            ("f", "_", ["_", "f"]),
            ("g", "&", ["&", "ğ", "ģ", "g"]),
            ("h", "-", ["-", "ħ", "h"]),
            ("j", "+", ["+", "j"]),
            ("k", "(", ["(", "ķ", "k"]),
            ("l", ")", [")", "ł", "ľ", "ļ", "l"])
        ]

        let row3Data: [(String, String, [String])] = [
            ("z", "*", ["*", "ž", "ź", "ż", "z"]),
            ("x", "\"", ["\"", "x"]),
            ("c", "'", ["'", "ç", "ć", "č", "c"]),
            ("v", ":", [":", "v"]),
            ("b", ";", [";", "b"]),
            ("n", "!", ["!", "ñ", "ń", "ň", "ņ", "n"]),
            ("m", "?", ["?", "m"])
        ]

        let row1 = row1Data.map {
            KeyModel(
                id: "q1_\($0.0)_\(showSecondary)",
                primaryText: $0.0,
                secondaryText: showSecondary ? $0.1 : nil,
                alternateVariants: $0.2,
                type: .secondaryCharacter(primary: $0.0, secondary: $0.1)
            )
        }

        let row2 = row2Data.map {
            KeyModel(
                id: "q2_\($0.0)_\(showSecondary)",
                primaryText: $0.0,
                secondaryText: showSecondary ? $0.1 : nil,
                alternateVariants: $0.2,
                type: .secondaryCharacter(primary: $0.0, secondary: $0.1)
            )
        }

        var row3: [KeyModel] = [
            KeyModel(id: "shift_key", primaryText: "shift", type: .shift, widthMultiplier: 1.35)
        ]
        row3.append(contentsOf: row3Data.map {
            KeyModel(
                id: "q3_\($0.0)_\(showSecondary)",
                primaryText: $0.0,
                secondaryText: showSecondary ? $0.1 : nil,
                alternateVariants: $0.2,
                type: .secondaryCharacter(primary: $0.0, secondary: $0.1)
            )
        })
        row3.append(KeyModel(id: "backspace_qwerty", primaryText: "delete", type: .backspace, widthMultiplier: 1.35))

        return [row1, row2, row3]
    }

    private static func buildNumberAndPunctuationRows() -> [[KeyModel]] {
        let row1: [(String, [String])] = [
            ("1", ["¹", "½", "⅓", "¼", "⅛", "₁"]),
            ("2", ["²", "⅔", "₂"]),
            ("3", ["³", "¾", "⅜", "₃"]),
            ("4", ["⁴", "₄"]),
            ("5", ["⁵", "⅝", "₅"]),
            ("6", ["⁶", "₆"]),
            ("7", ["⁷", "⅞", "₇"]),
            ("8", ["⁸", "∞", "₈"]),
            ("9", ["⁹", "₉"]),
            ("0", ["⁰", "∅", "₀"])
        ]
        let row2: [(String, [String])] = [
            ("-", ["–", "—", "•", "±"]),
            ("/", ["\\", "÷", "⁄"]),
            (":", ["…"]),
            (";", ["…"]),
            ("(", ["[", "{", "<", "«"]),
            (")", ["]", "}", ">", "»"]),
            ("$", ["¢", "£", "€", "¥", "₹", "₿", "₩"]),
            ("&", ["§"]),
            ("@", ["©", "®", "™"]),
            ("\"", ["“", "”", "„", "«", "»"])
        ]
        let row3Chars: [(String, [String])] = [
            (".", ["…", "•", "·"]),
            (",", ["‚", "‹", "›"]),
            ("?", ["¿", "‽"]),
            ("!", ["¡", "‼"]),
            ("'", ["‘", "’", "`", "´"])
        ]

        let r1 = row1.map { KeyModel(id: "n1_\($0.0)", primaryText: $0.0, alternateVariants: $0.1, type: .character($0.0)) }
        let r2 = row2.map { KeyModel(id: "n2_\($0.0)", primaryText: $0.0, alternateVariants: $0.1, type: .character($0.0)) }

        var r3: [KeyModel] = [
            KeyModel(id: "sym_toggle", primaryText: "#+=", type: .symbolToggle, widthMultiplier: 1.35)
        ]
        r3.append(contentsOf: row3Chars.map {
            KeyModel(id: "n3_\($0.0)", primaryText: $0.0, alternateVariants: $0.1, type: .character($0.0))
        })
        r3.append(KeyModel(id: "backspace_num", primaryText: "delete", type: .backspace, widthMultiplier: 1.35))

        return [r1, r2, r3]
    }
}
