import UIKit

// Unified font management system - Using elegant SF Pro font variants
struct FontManager {

    // MARK: - Display Fonts (Large Titles)
    static func displayLarge() -> UIFont {
        return UIFont(name: "SFProDisplay-Black", size: 52) ?? UIFont.systemFont(ofSize: 52, weight: .black)
    }

    static func displayMedium() -> UIFont {
        return UIFont(name: "SFProDisplay-Bold", size: 42) ?? UIFont.systemFont(ofSize: 42, weight: .bold)
    }

    static func displaySmall() -> UIFont {
        return UIFont(name: "SFProDisplay-Semibold", size: 32) ?? UIFont.systemFont(ofSize: 32, weight: .semibold)
    }

    // MARK: - Headline Fonts (Titles)
    static func headlineLarge() -> UIFont {
        return UIFont(name: "SFProDisplay-Bold", size: 28) ?? UIFont.systemFont(ofSize: 28, weight: .bold)
    }

    static func headlineMedium() -> UIFont {
        return UIFont(name: "SFProDisplay-Semibold", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .semibold)
    }

    static func headlineSmall() -> UIFont {
        return UIFont(name: "SFProDisplay-Medium", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .medium)
    }

    // MARK: - Body Fonts (Body Text)
    static func bodyLarge() -> UIFont {
        return UIFont(name: "SFProText-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .regular)
    }

    static func bodyMedium() -> UIFont {
        return UIFont(name: "SFProText-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .regular)
    }

    static func bodySmall() -> UIFont {
        return UIFont(name: "SFProText-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .regular)
    }

    // MARK: - Label Fonts (Labels)
    static func labelLarge() -> UIFont {
        return UIFont(name: "SFProText-Semibold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .semibold)
    }

    static func labelMedium() -> UIFont {
        return UIFont(name: "SFProText-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
    }

    static func labelSmall() -> UIFont {
        return UIFont(name: "SFProText-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .regular)
    }

    // MARK: - Monospaced Fonts (Monospaced - for timers)
    static func monospacedLarge() -> UIFont {
        return UIFont.monospacedDigitSystemFont(ofSize: 48, weight: .bold)
    }

    static func monospacedMedium() -> UIFont {
        return UIFont.monospacedDigitSystemFont(ofSize: 28, weight: .semibold)
    }

    static func monospacedSmall() -> UIFont {
        return UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .medium)
    }

    // MARK: - Button Fonts (Buttons)
    static func buttonLarge() -> UIFont {
        return UIFont(name: "SFProDisplay-Semibold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .semibold)
    }

    static func buttonMedium() -> UIFont {
        return UIFont(name: "SFProDisplay-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
    }

    static func buttonSmall() -> UIFont {
        return UIFont(name: "SFProDisplay-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .regular)
    }

    // MARK: - Caption Fonts (Caption Text)
    static func caption() -> UIFont {
        return UIFont(name: "SFProText-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .regular)
    }

    static func captionBold() -> UIFont {
        return UIFont(name: "SFProText-Semibold", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .semibold)
    }

    // MARK: - Dynamic Grid Font (Dynamically adjusted based on grid size)
    static func gridNumber(forCellSize size: CGFloat) -> UIFont {
        let fontSize = size * 0.35
        return UIFont(name: "SFProDisplay-Bold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .bold)
    }
}
