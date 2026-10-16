import SwiftUI

public enum KeycapStyle: String, Codable, CaseIterable {
    case iosLiquidGlass = "iOS Liquid Glass"
    case belkaRounded = "Belka Pill (Material 3)"
    case classic = "Classic Rectangular"

    public var cornerRadius: CGFloat {
        switch self {
        case .iosLiquidGlass: return 8.5
        case .belkaRounded: return 12.0
        case .classic: return 5.5
        }
    }
}

public struct KeyboardTheme: Identifiable, Codable, Equatable {
    public let id: String
    public let name: String
    public let isDark: Bool
    public let backgroundColorHex: String
    public let keyColorHex: String
    public let functionalKeyColorHex: String
    public let accentColorHex: String
    public let textPrimaryHex: String
    public let textSecondaryHex: String
    public let useFrostedGlass: Bool

    public init(
        id: String,
        name: String,
        isDark: Bool,
        backgroundColorHex: String,
        keyColorHex: String,
        functionalKeyColorHex: String,
        accentColorHex: String,
        textPrimaryHex: String,
        textSecondaryHex: String,
        useFrostedGlass: Bool = false
    ) {
        self.id = id
        self.name = name
        self.isDark = isDark
        self.backgroundColorHex = backgroundColorHex
        self.keyColorHex = keyColorHex
        self.functionalKeyColorHex = functionalKeyColorHex
        self.accentColorHex = accentColorHex
        self.textPrimaryHex = textPrimaryHex
        self.textSecondaryHex = textSecondaryHex
        self.useFrostedGlass = useFrostedGlass
    }

    // Apple iOS 26 Liquid Glass Dark (Transparent container + uniform translucent glass keys RGB ~70,70,70)
    public static let iosNativeDark = KeyboardTheme(
        id: "ios_native_dark",
        name: "iOS Liquid Glass Dark",
        isDark: true,
        backgroundColorHex: "#00000000",
        keyColorHex: "#36FFFFFF",
        functionalKeyColorHex: "#36FFFFFF",
        accentColorHex: "#0A84FF",
        textPrimaryHex: "#FFFFFF",
        textSecondaryHex: "#8CFFFFFF",
        useFrostedGlass: true
    )

    // Apple iOS 26 Liquid Glass Light
    public static let iosNativeLight = KeyboardTheme(
        id: "ios_native_light",
        name: "iOS Liquid Glass Light",
        isDark: false,
        backgroundColorHex: "#00000000",
        keyColorHex: "#D9FFFFFF",
        functionalKeyColorHex: "#B8FFFFFF",
        accentColorHex: "#007AFF",
        textPrimaryHex: "#000000",
        textSecondaryHex: "#7A000000",
        useFrostedGlass: true
    )

    // Google Material 3 Dynamic Pixel Theme
    public static let material3Dynamic = KeyboardTheme(
        id: "material3_dynamic",
        name: "Material 3 Dynamic (Pixel)",
        isDark: false,
        backgroundColorHex: "#F2F4F7",
        keyColorHex: "#FFFFFF",
        functionalKeyColorHex: "#DCE1E9",
        accentColorHex: "#1A73E8",
        textPrimaryHex: "#1F1F1F",
        textSecondaryHex: "#5E6368",
        useFrostedGlass: false
    )

    // AMOLED True Black
    public static let amoledBlack = KeyboardTheme(
        id: "amoled_black",
        name: "AMOLED True Black",
        isDark: true,
        backgroundColorHex: "#000000",
        keyColorHex: "#181818",
        functionalKeyColorHex: "#282828",
        accentColorHex: "#8AB4F8",
        textPrimaryHex: "#E8EAED",
        textSecondaryHex: "#9AA0A6",
        useFrostedGlass: false
    )

    // Frosted Glass Blur
    public static let frostedGlass = KeyboardTheme(
        id: "frosted_glass",
        name: "Frosted Glass Blur",
        isDark: true,
        backgroundColorHex: "#00000000",
        keyColorHex: "#36FFFFFF",
        functionalKeyColorHex: "#36FFFFFF",
        accentColorHex: "#0A84FF",
        textPrimaryHex: "#FFFFFF",
        textSecondaryHex: "#99EBEBF5",
        useFrostedGlass: true
    )

    // Pixel Ocean Blue
    public static let pixelBlue = KeyboardTheme(
        id: "pixel_blue",
        name: "Pixel Ocean Blue",
        isDark: true,
        backgroundColorHex: "#101D2D",
        keyColorHex: "#1D2B3A",
        functionalKeyColorHex: "#2B3C50",
        accentColorHex: "#58A6FF",
        textPrimaryHex: "#F0F6FC",
        textSecondaryHex: "#8B949E",
        useFrostedGlass: false
    )

    // Sage Mint Green
    public static let mintGreen = KeyboardTheme(
        id: "mint_green",
        name: "Sage Mint Green",
        isDark: false,
        backgroundColorHex: "#E8F0EA",
        keyColorHex: "#FFFFFF",
        functionalKeyColorHex: "#D5E3D8",
        accentColorHex: "#2D6A4F",
        textPrimaryHex: "#1B4332",
        textSecondaryHex: "#52796F",
        useFrostedGlass: false
    )

    public static let allThemes: [KeyboardTheme] = [
        iosNativeDark, iosNativeLight, material3Dynamic, amoledBlack, frostedGlass, pixelBlue, mintGreen
    ]
}
