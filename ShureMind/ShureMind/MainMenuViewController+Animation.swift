import UIKit

// MARK: - Animation Configuration
extension MainMenuViewController {
    struct AnimationConstants {
        static let decorativeCircleDuration: TimeInterval = 1.0
        static let decorativeCircleDelay: TimeInterval = 0

        static let streakIndicatorDuration: TimeInterval = 0.5
        static let streakIndicatorDelay: TimeInterval = 0.1

        static let titleDuration: TimeInterval = 0.8
        static let titleDelay: TimeInterval = 0.2
        static let titleSpringDamping: CGFloat = 0.5
        static let titleSpringVelocity: CGFloat = 0.8

        static let subtitleDuration: TimeInterval = 0.6
        static let subtitleDelay: TimeInterval = 0.4

        static let buttonBaseDuration: TimeInterval = 0.6
        static let buttonBaseDelay: TimeInterval = 0.6
        static let buttonStaggerDelay: TimeInterval = 0.12
        static let buttonSpringDamping: CGFloat = 0.7
        static let buttonSpringVelocity: CGFloat = 0.5

        static let versionLabelDuration: TimeInterval = 0.5
        static let versionLabelDelay: TimeInterval = 1.2

        static let hapticFeedbackDelay: TimeInterval = 0.3

        static let initialScale: CGFloat = 0.5
        static let buttonTranslationX: CGFloat = -50
        static let subtitleTranslationY: CGFloat = 20
    }

    func performEntranceAnimation() {
        prepareViewsForAnimation()
        animateDecorativeElements()
        animateStreakIndicator()
        animateTitle()
        animateSubtitle()
        animateButtons()
        animateVersionLabel()
        triggerHapticFeedback()
    }

    private func prepareViewsForAnimation() {
        titleLabel.alpha = 0
        subtitleLabel.alpha = 0
        streakIndicator.alpha = 0
        titleLabel.transform = CGAffineTransform(
            scaleX: AnimationConstants.initialScale,
            y: AnimationConstants.initialScale
        )
        subtitleLabel.transform = CGAffineTransform(
            translationX: 0,
            y: AnimationConstants.subtitleTranslationY
        )
        buttonStackView.arrangedSubviews.forEach { $0.alpha = 0 }
        versionLabel.alpha = 0
        decorativeCircle1.alpha = 0
        decorativeCircle2.alpha = 0
    }

    private func animateDecorativeElements() {
        UIView.animate(
            withDuration: AnimationConstants.decorativeCircleDuration,
            delay: AnimationConstants.decorativeCircleDelay,
            options: .curveEaseOut
        ) {
            self.decorativeCircle1.alpha = 1
            self.decorativeCircle2.alpha = 1
        }
    }

    private func animateStreakIndicator() {
        UIView.animate(
            withDuration: AnimationConstants.streakIndicatorDuration,
            delay: AnimationConstants.streakIndicatorDelay,
            options: .curveEaseOut
        ) {
            self.streakIndicator.alpha = 1
        }
    }

    private func animateTitle() {
        UIView.animate(
            withDuration: AnimationConstants.titleDuration,
            delay: AnimationConstants.titleDelay,
            usingSpringWithDamping: AnimationConstants.titleSpringDamping,
            initialSpringVelocity: AnimationConstants.titleSpringVelocity,
            options: .curveEaseOut
        ) {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = .identity
        }
    }

    private func animateSubtitle() {
        UIView.animate(
            withDuration: AnimationConstants.subtitleDuration,
            delay: AnimationConstants.subtitleDelay,
            options: .curveEaseOut
        ) {
            self.subtitleLabel.alpha = 0.9
            self.subtitleLabel.transform = .identity
        }
    }

    private func animateButtons() {
        for (index, button) in buttonStackView.arrangedSubviews.enumerated() {
            button.transform = CGAffineTransform(
                translationX: AnimationConstants.buttonTranslationX,
                y: 0
            )

            let delay = AnimationConstants.buttonBaseDelay + Double(index) * AnimationConstants.buttonStaggerDelay

            UIView.animate(
                withDuration: AnimationConstants.buttonBaseDuration,
                delay: delay,
                usingSpringWithDamping: AnimationConstants.buttonSpringDamping,
                initialSpringVelocity: AnimationConstants.buttonSpringVelocity
            ) {
                button.alpha = 1
                button.transform = .identity
            }
        }
    }

    private func animateVersionLabel() {
        UIView.animate(
            withDuration: AnimationConstants.versionLabelDuration,
            delay: AnimationConstants.versionLabelDelay
        ) {
            self.versionLabel.alpha = 1
        }
    }

    private func triggerHapticFeedback() {
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstants.hapticFeedbackDelay) {
            HapticFeedbackEngine.shared.triggerSuccess()
        }
    }
}
