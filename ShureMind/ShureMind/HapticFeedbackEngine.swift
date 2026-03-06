import UIKit

// Haptic feedback manager for tactile responses
class HapticFeedbackEngine {
    static let shared = HapticFeedbackEngine()

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()

    private init() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
    }

    func triggerSelection() {
        selectionGenerator.selectionChanged()
    }

    func triggerSuccess() {
        notificationGenerator.notificationOccurred(.success)
    }

    func triggerError() {
        notificationGenerator.notificationOccurred(.error)
    }

    func triggerImpact(intensity: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        switch intensity {
        case .light:
            impactLight.impactOccurred()
        case .medium:
            impactMedium.impactOccurred()
        case .heavy:
            impactHeavy.impactOccurred()
        default:
            impactMedium.impactOccurred()
        }
    }
}
