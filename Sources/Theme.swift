// --- START OF FILE GolfTracker.swiftpm/Sources/Theme.swift ---
import SwiftUI

// Define the Theme constants
struct Theme {

    // MARK: - Colors (Using Hex for Custom, SwiftUI defaults where appropriate)

    // 60% - Backgrounds
    static let background = Color(.systemGroupedBackground) // Use system for adaptability
    static let surface = Color(.secondarySystemGroupedBackground) // Use system for card backgrounds etc.

    // 10% / Semantic - Accents & Indicators
    static let accentPrimary = Color(hex: "1A8C4D") // Deep Golf Green (Keep custom)
    static let accentSecondary = Color.blue           // Standard Blue (System default)
    static let positive = accentPrimary               // Use Green for positive stats/indicators
    static let negative = Color.red                   // Standard Red (Over par, warnings, delete)
    static let warning = Color.orange                 // Standard Orange (Missed fairway direction)
    static let neutral = Color.gray                   // Standard Gray (Less prominent elements)
    static let chartLine = accentPrimary              // Default chart line color

    // Text Colors
    static let textPrimary = Color.primary            // Adapts to light/dark mode
    static let textSecondary = Color.secondary        // Adapts to light/dark mode
    static let textOnAccent = Color.white             // Text on dark green/blue backgrounds
    static let textDisabled = Color.gray.opacity(0.6) // System gray, slightly faded

    // Component Specific
    static let divider = Color(.separator)            // System default for dividers

    // MARK: - Typography (Using System Fonts)

    static func font(style: Font.TextStyle, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
        .system(style, design: design, weight: weight)
    }

    // Example Hierarchy (Adjust styles/weights as needed)
    static let fontDisplayLarge = font(style: .largeTitle, weight: .bold)
    static let fontTitle1 = font(style: .title, weight: .semibold)
    static let fontTitle2 = font(style: .title2, weight: .semibold)
    static let fontTitle3 = font(style: .title3, weight: .medium)
    static let fontHeadline = font(style: .headline, weight: .semibold) // Good for section headers
    static let fontBody = font(style: .body)                           // Standard text
    static let fontBodySemibold = font(style: .body, weight: .semibold)
    static let fontCallout = font(style: .callout)
    static let fontSubheadline = font(style: .subheadline)             // Good for secondary info under headlines
    static let fontFootnote = font(style: .footnote)
    static let fontCaption = font(style: .caption)
    static let fontCaptionBold = font(style: .caption, weight: .bold)
    static let fontCaption2 = font(style: .caption2)

    // MARK: - Spacing (8pt Grid)

    static let spacingXXS: CGFloat = 4
    static let spacingXS: CGFloat = 8
    static let spacingS: CGFloat = 12 // Can use 12 sometimes for tighter UI
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32
    static let spacingXXL: CGFloat = 40

    // MARK: - Corner Radius
    static let cornerRadiusS: CGFloat = 8
    static let cornerRadiusM: CGFloat = 12
    static let cornerRadiusL: CGFloat = 16

    // MARK: - Shadows (Using Standard View Modifiers)

    // Define ViewModifiers for applying standard shadows consistently
    struct StandardShadow: ViewModifier {
        func body(content: Content) -> some View {
            content
                .shadow(color: Theme.neutral.opacity(0.15), radius: 8, x: 0, y: 4) // Adjusted opacity/color
        }
    }

    struct SubtleShadow: ViewModifier {
        func body(content: Content) -> some View {
            content
                .shadow(color: Theme.neutral.opacity(0.10), radius: 5, x: 0, y: 2) // Adjusted opacity/color
        }
    }

    // Static instances of the modifiers for easy use: .modifier(Theme.standardShadow)
    static let standardShadow = StandardShadow()
    static let subtleShadow = SubtleShadow()
}

// MARK: - Color Hex Initializer Extension
// Keep ONLY this one definition of the hex initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0) // Default to black if invalid format
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
// --- END OF FILE GolfTracker.swiftpm/Sources/Theme.swift ---
