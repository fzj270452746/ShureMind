import Foundation
import UIKit

// Theme type
enum ThemeType: String, Codable {
    case neonDark = "Neon Dark"
    case oceanBlue = "Ocean Blue"
    case sunsetOrange = "Sunset Orange"
    case forestGreen = "Forest Green"
    case royalPurple = "Royal Purple"
}

// Theme manager
class ThemeManager {
    static let shared = ThemeManager()
    private let userDefaults = UserDefaults.standard
    private let themeKey = "selectedTheme"

    private init() {}

    // Get current theme
    func getCurrentTheme() -> ThemeType {
        if let themeString = userDefaults.string(forKey: themeKey),
           let theme = ThemeType(rawValue: themeString) {
            return theme
        }
        return .neonDark // Default theme
    }

    // Set theme
    func setTheme(_ theme: ThemeType) {
        userDefaults.set(theme.rawValue, forKey: themeKey)
        NotificationCenter.default.post(name: NSNotification.Name("ThemeChanged"), object: theme)
    }

    // Get theme colors
    func getThemeColors(for theme: ThemeType) -> ThemeColors {
        switch theme {
        case .neonDark:
            return ThemeColors(
                bgGradientTop: UIColor(red: 0.05, green: 0.02, blue: 0.15, alpha: 1.0),
                bgGradientMid: UIColor(red: 0.10, green: 0.05, blue: 0.25, alpha: 1.0),
                bgGradientBottom: UIColor(red: 0.15, green: 0.08, blue: 0.35, alpha: 1.0),
                accent1: UIColor(red: 0.0, green: 0.95, blue: 1.0, alpha: 1.0),
                accent2: UIColor(red: 0.65, green: 0.20, blue: 1.0, alpha: 1.0),
                accent3: UIColor(red: 1.0, green: 0.20, blue: 0.70, alpha: 1.0)
            )
        case .oceanBlue:
            return ThemeColors(
                bgGradientTop: UIColor(red: 0.02, green: 0.10, blue: 0.20, alpha: 1.0),
                bgGradientMid: UIColor(red: 0.05, green: 0.20, blue: 0.35, alpha: 1.0),
                bgGradientBottom: UIColor(red: 0.10, green: 0.30, blue: 0.50, alpha: 1.0),
                accent1: UIColor(red: 0.0, green: 0.80, blue: 1.0, alpha: 1.0),
                accent2: UIColor(red: 0.20, green: 0.60, blue: 0.90, alpha: 1.0),
                accent3: UIColor(red: 0.40, green: 0.90, blue: 1.0, alpha: 1.0)
            )
        case .sunsetOrange:
            return ThemeColors(
                bgGradientTop: UIColor(red: 0.20, green: 0.05, blue: 0.10, alpha: 1.0),
                bgGradientMid: UIColor(red: 0.35, green: 0.10, blue: 0.15, alpha: 1.0),
                bgGradientBottom: UIColor(red: 0.50, green: 0.15, blue: 0.20, alpha: 1.0),
                accent1: UIColor(red: 1.0, green: 0.50, blue: 0.0, alpha: 1.0),
                accent2: UIColor(red: 1.0, green: 0.30, blue: 0.30, alpha: 1.0),
                accent3: UIColor(red: 1.0, green: 0.70, blue: 0.20, alpha: 1.0)
            )
        case .forestGreen:
            return ThemeColors(
                bgGradientTop: UIColor(red: 0.05, green: 0.15, blue: 0.10, alpha: 1.0),
                bgGradientMid: UIColor(red: 0.10, green: 0.25, blue: 0.15, alpha: 1.0),
                bgGradientBottom: UIColor(red: 0.15, green: 0.35, blue: 0.20, alpha: 1.0),
                accent1: UIColor(red: 0.20, green: 1.0, blue: 0.60, alpha: 1.0),
                accent2: UIColor(red: 0.40, green: 0.90, blue: 0.40, alpha: 1.0),
                accent3: UIColor(red: 0.60, green: 1.0, blue: 0.80, alpha: 1.0)
            )
        case .royalPurple:
            return ThemeColors(
                bgGradientTop: UIColor(red: 0.15, green: 0.05, blue: 0.20, alpha: 1.0),
                bgGradientMid: UIColor(red: 0.25, green: 0.10, blue: 0.35, alpha: 1.0),
                bgGradientBottom: UIColor(red: 0.35, green: 0.15, blue: 0.50, alpha: 1.0),
                accent1: UIColor(red: 0.80, green: 0.30, blue: 1.0, alpha: 1.0),
                accent2: UIColor(red: 0.60, green: 0.20, blue: 0.90, alpha: 1.0),
                accent3: UIColor(red: 1.0, green: 0.50, blue: 0.90, alpha: 1.0)
            )
        }
    }
}

// Theme colors structure
struct ThemeColors {
    let bgGradientTop: UIColor
    let bgGradientMid: UIColor
    let bgGradientBottom: UIColor
    let accent1: UIColor
    let accent2: UIColor
    let accent3: UIColor
}

// Settings manager
class SettingsManager {
    static let shared = SettingsManager()
    private let userDefaults = UserDefaults.standard

    private let soundEffectsKey = "soundEffectsEnabled"
    private let hapticsKey = "hapticsEnabled"
    private let notificationsKey = "notificationsEnabled"

    private init() {}

    // Sound effects setting
    var soundEffectsEnabled: Bool {
        get {
            return userDefaults.bool(forKey: soundEffectsKey)
        }
        set {
            userDefaults.set(newValue, forKey: soundEffectsKey)
        }
    }

    // Haptic feedback setting
    var hapticsEnabled: Bool {
        get {
            // Default enabled
            if userDefaults.object(forKey: hapticsKey) == nil {
                return true
            }
            return userDefaults.bool(forKey: hapticsKey)
        }
        set {
            userDefaults.set(newValue, forKey: hapticsKey)
        }
    }

    // Notification setting
    var notificationsEnabled: Bool {
        get {
            return userDefaults.bool(forKey: notificationsKey)
        }
        set {
            userDefaults.set(newValue, forKey: notificationsKey)
        }
    }
}
