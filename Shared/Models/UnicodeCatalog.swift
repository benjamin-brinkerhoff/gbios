import Foundation

public struct UnicodeCategory: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let icon: String
    public let characters: [String]
}

public final class UnicodeCatalog {
    public static let shared = UnicodeCatalog()
    public let categories: [UnicodeCategory]

    private init() {
        var list: [UnicodeCategory] = []

        let common = [
            "~", "`", "|", "•", "√", "π", "÷", "×", "§", "∆",
            "£", "¢", "€", "¥", "^", "°", "=", "{", "}", "\\",
            "%", "©", "®", "™", "✓", "[", "]", "¡", "¿", "«",
            "»", "‹", "›", "–", "—", "…", "†", "‡", "‰", "№",
            "℃", "℉", "℗", "℠", "⁂", "‽", "¶", "¤", "¦", "¨",
            "¯", "´", "¸", "º", "ª", "·", "‚", "„", "“", "”",
            "‘", "’", "′", "″", "‴", "‸", "※", "‾", "‿", "⁀"
        ]
        list.append(UnicodeCategory(id: "common", title: "Common", icon: "number", characters: common))

        var mathChars: [String] = [
            "±", "×", "÷", "≠", "≈", "≡", "≤", "≥", "≪", "≫",
            "∞", "√", "∛", "∜", "∑", "∏", "∫", "∬", "∭", "∮",
            "∂", "∇", "∆", "∈", "∉", "∋", "⊂", "⊃", "⊆", "⊇",
            "∪", "∩", "∅", "∀", "∃", "∄", "¬", "∧", "∨", "⊕",
            "⊗", "⊥", "∥", "∠", "∟", "∴", "∵", "∝", "ℝ", "ℤ",
            "ℚ", "ℕ", "ℂ", "ℵ", "ℏ", "ℓ", "℘", "ℜ", "ℑ"
        ]
        mathChars.append(contentsOf: Self.scalars(in: 0x2200...0x22FF))
        list.append(UnicodeCategory(id: "math", title: "Math", icon: "function", characters: Self.dedup(mathChars)))

        let superSub = [
            "⁰", "¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹",
            "⁺", "⁻", "⁼", "⁽", "⁾", "ⁿ", "ⁱ", "ᵃ", "ᵇ", "ᶜ",
            "ᵈ", "ᵉ", "ᶠ", "ᵍ", "ʰ", "ʲ", "ᵏ", "ˡ", "ᵐ", "ᵒ",
            "ᵖ", "ʳ", "ˢ", "ᵗ", "ᵘ", "ᵛ", "ʷ", "ˣ", "ʸ", "ᶻ",
            "₀", "₁", "₂", "₃", "₄", "₅", "₆", "₇", "₈", "₉",
            "₊", "₋", "₌", "₍", "₎", "ₐ", "ₑ", "ₒ", "ₓ", "ₕ",
            "ₖ", "ₗ", "ₘ", "ₙ", "ₚ", "ₛ", "ₜ",
            "½", "⅓", "⅔", "¼", "¾", "⅕", "⅖", "⅗", "⅘", "⅙",
            "⅚", "⅛", "⅜", "⅝", "⅞", "⅟", "↉"
        ]
        list.append(UnicodeCategory(id: "supersub", title: "Super/Fractions", icon: "textformat.superscript", characters: superSub))

        var arrows = Self.scalars(in: 0x2190...0x21FF)
        arrows.append(contentsOf: Self.scalars(in: 0x27F0...0x27FF))
        list.append(UnicodeCategory(id: "arrows", title: "Arrows", icon: "arrow.left.arrow.right", characters: Self.dedup(arrows)))

        var currencyTech: [String] = [
            "$", "¢", "£", "¤", "¥", "€", "₹", "₽", "₿", "₩",
            "₪", "₫", "₴", "₦", "₱", "₲", "₵", "₸", "₺", "₼",
            "₾", "⌘", "⌥", "⌃", "⇧", "⇪", "", "⌫", "⌦", "⏎",
            "⎋", "⇥", "␣", "⚙", "⚡", "⚠"
        ]
        currencyTech.append(contentsOf: Self.scalars(in: 0x20A0...0x20BF))
        currencyTech.append(contentsOf: Self.scalars(in: 0x2300...0x23FA))
        list.append(UnicodeCategory(id: "currency", title: "Currency & Tech", icon: "dollarsign.circle", characters: Self.dedup(currencyTech)))

        var shapes = Self.scalars(in: 0x25A0...0x25FF)
        shapes.append(contentsOf: Self.scalars(in: 0x2500...0x259F))
        list.append(UnicodeCategory(id: "shapes", title: "Shapes & Box", icon: "square.on.circle", characters: Self.dedup(shapes)))

        var misc = Self.scalars(in: 0x2600...0x26FF)
        misc.append(contentsOf: Self.scalars(in: 0x2700...0x27BF))
        list.append(UnicodeCategory(id: "misc", title: "Symbols & Music", icon: "sparkles", characters: Self.dedup(misc)))

        var greekIPA = Self.scalars(in: 0x0391...0x03C9)
        greekIPA.append(contentsOf: Self.scalars(in: 0x0250...0x02AF))
        greekIPA.append(contentsOf: Self.scalars(in: 0x0410...0x044F))
        list.append(UnicodeCategory(id: "greek", title: "Greek & IPA", icon: "character.book.closed", characters: Self.dedup(greekIPA)))

        let enclosed = Self.scalars(in: 0x2460...0x24FF)
        list.append(UnicodeCategory(id: "enclosed", title: "Circled", icon: "a.circle", characters: enclosed))

        var styledFonts: [String] = []
        styledFonts.append(contentsOf: Self.scalars(in: 0x1D400...0x1D433))
        styledFonts.append(contentsOf: Self.scalars(in: 0x1D4D0...0x1D503))
        styledFonts.append(contentsOf: Self.scalars(in: 0x1D538...0x1D56B))
        styledFonts.append(contentsOf: Self.scalars(in: 0x1D56C...0x1D59F))
        styledFonts.append(contentsOf: Self.scalars(in: 0x1D670...0x1D6A3))
        list.append(UnicodeCategory(id: "fonts", title: "Fancy Fonts", icon: "textformat", characters: Self.dedup(styledFonts)))

        self.categories = list
    }

    private static func scalars(in range: ClosedRange<UInt32>) -> [String] {
        var result: [String] = []
        for code in range {
            if let scalar = UnicodeScalar(code),
               scalar.properties.generalCategory != .control,
               scalar.properties.generalCategory != .unassigned,
               scalar.properties.generalCategory != .privateUse {
                result.append(String(scalar))
            }
        }
        return result
    }

    private static func dedup(_ items: [String]) -> [String] {
        var seen = Set<String>()
        var out: [String] = []
        for item in items {
            if !seen.contains(item) {
                seen.insert(item)
                out.append(item)
            }
        }
        return out
    }
}
