import UIKit

// MARK: - Layout Configuration
extension MainMenuViewController {
    struct LayoutConstants {
        static let streakIndicatorTopOffset: CGFloat = 8
        static let streakIndicatorWidth: CGFloat = 200
        static let streakIndicatorHeight: CGFloat = 36
        static let streakIndicatorCornerRadius: CGFloat = 18

        static let profileViewTopOffset: CGFloat = 6
        static let logoContainerTopOffset: CGFloat = 10
        static let logoContainerWidthMultiplier: CGFloat = 0.9
        static let logoContainerHeight: CGFloat = 70

        static let titleSubtitleSpacing: CGFloat = 4

        static let buttonStackTopOffset: CGFloat = 15
        static let buttonStackWidthMultiplier: CGFloat = 0.85
        static let buttonSpacing: CGFloat = 8

        static let versionLabelBottomOffset: CGFloat = -10

        static let decorativeCircle1Size: CGFloat = 300
        static let decorativeCircle1TrailingOffset: CGFloat = 100
        static let decorativeCircle1TopOffset: CGFloat = -50

        static let decorativeCircle2Size: CGFloat = 240
        static let decorativeCircle2LeadingOffset: CGFloat = -80
        static let decorativeCircle2BottomOffset: CGFloat = 50
    }

    func setupLayoutConstraints() {
        [logoContainer, titleLabel, subtitleLabel, buttonStackView,
         decorativeCircle1, decorativeCircle2, versionLabel,
         streakIndicator, streakLabel, profileView, levelLabel,
         tierLabel, expProgressView, expLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            // Streak indicator
            streakIndicator.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: LayoutConstants.streakIndicatorTopOffset
            ),
            streakIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            streakIndicator.widthAnchor.constraint(equalToConstant: LayoutConstants.streakIndicatorWidth),
            streakIndicator.heightAnchor.constraint(equalToConstant: LayoutConstants.streakIndicatorHeight),

            streakLabel.centerXAnchor.constraint(equalTo: streakIndicator.centerXAnchor),
            streakLabel.centerYAnchor.constraint(equalTo: streakIndicator.centerYAnchor),

            // Profile view
            profileView.topAnchor.constraint(equalTo: streakIndicator.bottomAnchor, constant: LayoutConstants.profileViewTopOffset),
            profileView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileView.widthAnchor.constraint(equalToConstant: 200),
            profileView.heightAnchor.constraint(equalToConstant: 80),

            levelLabel.topAnchor.constraint(equalTo: profileView.topAnchor, constant: 10),
            levelLabel.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 15),

            tierLabel.topAnchor.constraint(equalTo: profileView.topAnchor, constant: 12),
            tierLabel.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -15),

            expProgressView.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 10),
            expProgressView.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 15),
            expProgressView.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -15),
            expProgressView.heightAnchor.constraint(equalToConstant: 8),

            expLabel.topAnchor.constraint(equalTo: expProgressView.bottomAnchor, constant: 5),
            expLabel.centerXAnchor.constraint(equalTo: profileView.centerXAnchor),

            // Decorative circles
            decorativeCircle1.widthAnchor.constraint(equalToConstant: LayoutConstants.decorativeCircle1Size),
            decorativeCircle1.heightAnchor.constraint(equalToConstant: LayoutConstants.decorativeCircle1Size),
            decorativeCircle1.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: LayoutConstants.decorativeCircle1TrailingOffset
            ),
            decorativeCircle1.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: LayoutConstants.decorativeCircle1TopOffset
            ),

            decorativeCircle2.widthAnchor.constraint(equalToConstant: LayoutConstants.decorativeCircle2Size),
            decorativeCircle2.heightAnchor.constraint(equalToConstant: LayoutConstants.decorativeCircle2Size),
            decorativeCircle2.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: LayoutConstants.decorativeCircle2LeadingOffset
            ),
            decorativeCircle2.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: LayoutConstants.decorativeCircle2BottomOffset
            ),

            // Logo container
            logoContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoContainer.topAnchor.constraint(
                equalTo: profileView.bottomAnchor,
                constant: LayoutConstants.logoContainerTopOffset
            ),
            logoContainer.widthAnchor.constraint(
                equalTo: view.widthAnchor,
                multiplier: LayoutConstants.logoContainerWidthMultiplier
            ),
            logoContainer.heightAnchor.constraint(equalToConstant: LayoutConstants.logoContainerHeight),

            titleLabel.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: logoContainer.topAnchor),

            subtitleLabel.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor),
            subtitleLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: LayoutConstants.titleSubtitleSpacing
            ),

            // Button stack
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.topAnchor.constraint(
                equalTo: logoContainer.bottomAnchor,
                constant: LayoutConstants.buttonStackTopOffset
            ),
            buttonStackView.bottomAnchor.constraint(
                lessThanOrEqualTo: versionLabel.topAnchor,
                constant: -10
            ),
            buttonStackView.widthAnchor.constraint(
                equalTo: view.widthAnchor,
                multiplier: LayoutConstants.buttonStackWidthMultiplier
            ),

            // Version label
            versionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            versionLabel.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: LayoutConstants.versionLabelBottomOffset
            )
        ])
    }
}
