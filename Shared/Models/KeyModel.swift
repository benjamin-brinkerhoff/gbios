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

    // Page 1: Android Gboard Default QWERTY Matrix with Secondary Symbols & Long-Press Variants
    public static func defaultQwertyRows(showSecondary: Bool) -> [[KeyModel]] {
        let row1Data: [(String, String, [String])] = [
            ("q", "1", ["1", "q"]),
            ("w", "2", ["2", "w"]),
            ("e", "3", ["3", "é", "è", "ê", "ë", "ē", "e"]),
            ("r", "4", ["4", "r"]),
            ("t", "5", ["5", "þ", "t"]),
            ("y", "6", ["6", "ÿ", "y"]),
            ("u", "7", ["7", "ú", "ù", "û", "ü", "ū", "u"]),
            ("i", "8", ["8", "í", "ì", "î", "ï", "ī", "i"]),
            ("o", "9", ["9", "ó", "ò", "ô", "ö", "õ", "œ", "ø", "ō", "o"]),
            ("p", "0", ["0", "p"])
        ]

        let row2Data: [(String, String, [String])] = [
            ("a", "@", ["@", "á", "à", "â", "ä", "æ", "ã", "å", "ā", "a"]),
            ("s", "#", ["#", "ß", "ś", "š", "s"]),
            ("d", "$", ["$", "ð", "d"]),
            ("f", "_", ["_", "f"]),
            ("g", "&", ["&", "g"]),
            ("h", "-", ["-", "h"]),
            ("j", "+", ["+", "j"]),
            ("k", "(", ["(", "k"]),
            ("l", ")", [")", "ł", "l"])
        ]

        let row3Data: [(String, String, [String])] = [
            ("z", "*", ["*", "ž", "ź", "ż", "z"]),
            ("x", "\"", ["\"", "x"]),
            ("c", "'", ["'", "ç", "ć", "č", "c"]),
            ("v", ":", [":", "v"]),
            ("b", ";", [";", "b"]),
            ("n", "!", ["!", "ñ", "ń", "n"]),
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
            KeyModel(id: "shift_key", primaryText: "shift", type: .shift, widthMultiplier: 1.35)
        ]
        row3.append(contentsOf: row3Data.map {
            KeyModel(
                primaryText: $0.0,
                secondaryText: showSecondary ? $0.1 : nil,
                alternateVariants: $0.2,
                type: .secondaryCharacter(primary: $0.0, secondary: $0.1)
            )
        })
        row3.append(KeyModel(id: "backspace_qwerty", primaryText: "delete", type: .backspace, widthMultiplier: 1.35))

        return [row1, row2, row3]
    }

    // Page 2: Android Gboard Numbers & Punctuation Layout (?123)
    public static func numberAndPunctuationRows() -> [[KeyModel]] {
        let row1: [(String, [String])] = [
            ("1", ["¹", "½", "⅓", "¼", "⅛"]),
            ("2", ["²", "⅔"]),
            ("3", ["³", "¾", "⅜"]),
            ("4", ["⁴"]),
            ("5", ["⅝"]),
            ("6", []),
            ("7", ["⅞"]),
            ("8", ["∞"]),
            ("9", []),
            ("0", ["⁰", "∅"])
        ]
        let row2: [(String, [String])] = [
            ("@", []),
            ("#", ["№"]),
            ("$", ["¢", "£", "€", "¥", "₹"]),
            ("_", ["–", "—"]),
            ("&", []),
            ("-", ["–", "—", "•"]),
            ("+", ["±"]),
            ("(", ["[", "{", "<"]),
            (")", ["]", "}", ">"]),
            ("/", ["\\"])
        ]
        let row3Chars: [(String, [String])] = [
            ("*", ["†", "‡", "★"]),
            ("\"", ["“", "”", "«", "»"]),
            ("'", ["‘", "’", "‹", "›"]),
            (":", []),
            (";", []),
            ("!", ["¡"]),
            ("?", ["¿"])
        ]

        let r1 = row1.map { KeyModel(primaryText: $0.0, alternateVariants: $0.1, type: .character($0.0)) }
        let r2 = row2.map { KeyModel(primaryText: $0.0, alternateVariants: $0.1, type: .character($0.0)) }

        var r3: [KeyModel] = [
            KeyModel(id: "sym_toggle", primaryText: "=\\<", type: .symbolToggle, widthMultiplier: 1.35)
        ]
        r3.append(contentsOf: row3Chars.map {
            KeyModel(primaryText: $0.0, alternateVariants: $0.1, type: .character($0.0))
        })
        r3.append(KeyModel(id: "backspace_num", primaryText: "delete", type: .backspace, widthMultiplier: 1.35))

        return [r1, r2, r3]
    }

    // Page 3: Android Gboard Secondary Symbols Layout (=\<)
    public static func secondarySymbolRows() -> [[KeyModel]] {
        let row1 = ["~", "`", "|", "•", "√", "π", "÷", "×", "§", "∆"].map {
            KeyModel(primaryText: $0, type: .character($0))
        }
        let row2 = ["£", "¢", "€", "¥", "^", "°", "=", "{", "}", "\\"].map {
            KeyModel(primaryText: $0, type: .character($0))
        }
        let row3Chars = ["%", "©", "®", "™", "✓", "[", "]"].map {
            KeyModel(primaryText: $0, type: .character($0))
        }

        var r3: [KeyModel] = [
            KeyModel(id: "num_back_toggle", primaryText: "?123", type: .numberToggle, widthMultiplier: 1.35)
        ]
        r3.append(contentsOf: row3Chars)
        r3.append(KeyModel(id: "backspace_sym", primaryText: "delete", type: .backspace, widthMultiplier: 1.35))

        return [row1, row2, r3]
    }

    public static func dedicatedNumberRow() -> [KeyModel] {
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"].map {
            KeyModel(id: "numrow_\($0)", primaryText: $0, type: .character($0))
        }
    }
}
