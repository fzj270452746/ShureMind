import UIKit

// Professional game-style color theme
struct ColorPalette {
    // Background gradients - Deep space theme
    static let bgGradientTop = UIColor(red: 0.05, green: 0.02, blue: 0.15, alpha: 1.0)
    static let bgGradientMid = UIColor(red: 0.10, green: 0.05, blue: 0.25, alpha: 1.0)
    static let bgGradientBottom = UIColor(red: 0.15, green: 0.08, blue: 0.35, alpha: 1.0)

    // Neon accent colors
    static let neonCyan = UIColor(red: 0.0, green: 0.95, blue: 1.0, alpha: 1.0)
    static let neonPurple = UIColor(red: 0.65, green: 0.20, blue: 1.0, alpha: 1.0)
    static let neonPink = UIColor(red: 1.0, green: 0.20, blue: 0.70, alpha: 1.0)
    static let neonGreen = UIColor(red: 0.20, green: 1.0, blue: 0.60, alpha: 1.0)
    static let neonOrange = UIColor(red: 1.0, green: 0.50, blue: 0.0, alpha: 1.0)

    // Feedback colors with glow
    static let successGlow = UIColor(red: 0.0, green: 1.0, blue: 0.50, alpha: 1.0)
    static let errorPulse = UIColor(red: 1.0, green: 0.20, blue: 0.40, alpha: 1.0)
    static let warningGlow = UIColor(red: 1.0, green: 0.70, blue: 0.0, alpha: 1.0)

    // Card and panel colors with glass morphism
    static let cardGlass = UIColor(red: 0.15, green: 0.10, blue: 0.30, alpha: 0.6)
    static let cardGlassBorder = UIColor(red: 0.40, green: 0.30, blue: 0.70, alpha: 0.3)
    static let panelDark = UIColor(red: 0.08, green: 0.05, blue: 0.20, alpha: 0.9)

    // Button gradients - Multiple styles
    static let btnPrimaryStart = UIColor(red: 0.60, green: 0.15, blue: 1.0, alpha: 1.0)
    static let btnPrimaryEnd = UIColor(red: 0.0, green: 0.80, blue: 1.0, alpha: 1.0)

    static let btnSecondaryStart = UIColor(red: 1.0, green: 0.30, blue: 0.70, alpha: 1.0)
    static let btnSecondaryEnd = UIColor(red: 1.0, green: 0.60, blue: 0.20, alpha: 1.0)

    static let btnSuccessStart = UIColor(red: 0.0, green: 0.90, blue: 0.60, alpha: 1.0)
    static let btnSuccessEnd = UIColor(red: 0.20, green: 1.0, blue: 0.80, alpha: 1.0)

    // Text colors with hierarchy
    static let textPrimary = UIColor.white
    static let textSecondary = UIColor(red: 0.80, green: 0.85, blue: 1.0, alpha: 0.9)
    static let textTertiary = UIColor(red: 0.60, green: 0.70, blue: 0.90, alpha: 0.7)
    static let textGlow = UIColor(red: 0.0, green: 0.95, blue: 1.0, alpha: 1.0)

    // Grid cell colors with depth
    static let gridCellDefault = UIColor(red: 0.12, green: 0.08, blue: 0.28, alpha: 1.0)
    static let gridCellHover = UIColor(red: 0.20, green: 0.15, blue: 0.40, alpha: 1.0)
    static let gridCellBorder = UIColor(red: 0.40, green: 0.30, blue: 0.70, alpha: 0.5)

    // Shadow colors for depth
    static let shadowPurple = UIColor(red: 0.50, green: 0.20, blue: 0.90, alpha: 0.6)
    static let shadowCyan = UIColor(red: 0.0, green: 0.80, blue: 1.0, alpha: 0.5)
    static let shadowPink = UIColor(red: 1.0, green: 0.20, blue: 0.70, alpha: 0.4)

    // Legacy compatibility
    static let primaryDark = bgGradientTop
    static let primaryMid = bgGradientMid
    static let accentCyan = neonCyan
    static let accentPurple = neonPurple
    static let cardBackground = cardGlass
    static let buttonGradientStart = btnPrimaryStart
    static let buttonGradientEnd = btnPrimaryEnd
}
