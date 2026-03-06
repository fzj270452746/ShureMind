import UIKit

// Settings view controller
class SettingsViewController: UIViewController {
    private let headerView = UIView()
    private let backButton = UIButton()
    private let titleLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Theme selection
    private let themeLabel = UILabel()
    private let themeSegmentedControl = UISegmentedControl()

    // Switch settings
    private let soundEffectsLabel = UILabel()
    private let soundEffectsSwitch = UISwitch()
    private let hapticsLabel = UILabel()
    private let hapticsSwitch = UISwitch()

    // Statistics info
    private let statsContainerView = UIView()
    private let streakLabel = UILabel()
    private let achievementsLabel = UILabel()
    private let pointsLabel = UILabel()

    // About section
    private let aboutContainerView = UIView()
    private let aboutTitleLabel = UILabel()
    private let aboutDescriptionLabel = UILabel()
    private let feedbackButton = StylizedButton()
    private let versionInfoLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSettings()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyGradientBackground(colors: [ColorPalette.primaryDark, ColorPalette.primaryMid])
    }

    private func setupUI() {
        // Header
        headerView.backgroundColor = .clear
        view.addSubview(headerView)

        backButton.setTitle("←", for: .normal)
        backButton.titleLabel?.font = FontManager.displaySmall()
        backButton.setTitleColor(ColorPalette.textPrimary, for: .normal)
        backButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        headerView.addSubview(backButton)

        titleLabel.text = "Settings"
        titleLabel.font = FontManager.headlineLarge()
        titleLabel.textColor = ColorPalette.textPrimary
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)

        // Scroll view
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Theme selection
        themeLabel.text = "Theme"
        themeLabel.font = FontManager.headlineSmall()
        themeLabel.textColor = ColorPalette.textPrimary
        contentView.addSubview(themeLabel)

        themeSegmentedControl.insertSegment(withTitle: "Neon", at: 0, animated: false)
        themeSegmentedControl.insertSegment(withTitle: "Ocean", at: 1, animated: false)
        themeSegmentedControl.insertSegment(withTitle: "Sunset", at: 2, animated: false)
        themeSegmentedControl.insertSegment(withTitle: "Forest", at: 3, animated: false)
        themeSegmentedControl.insertSegment(withTitle: "Royal", at: 4, animated: false)
        themeSegmentedControl.selectedSegmentIndex = 0
        themeSegmentedControl.backgroundColor = ColorPalette.cardBackground
        themeSegmentedControl.selectedSegmentTintColor = ColorPalette.accentPurple
        themeSegmentedControl.setTitleTextAttributes([.foregroundColor: ColorPalette.textPrimary, .font: FontManager.labelMedium()], for: .normal)
        themeSegmentedControl.setTitleTextAttributes([.foregroundColor: ColorPalette.textPrimary, .font: FontManager.labelMedium()], for: .selected)
        themeSegmentedControl.addTarget(self, action: #selector(themeChanged), for: .valueChanged)
        contentView.addSubview(themeSegmentedControl)

        // Sound effects switch
        soundEffectsLabel.text = "Sound Effects"
        soundEffectsLabel.font = FontManager.bodyLarge()
        soundEffectsLabel.textColor = ColorPalette.textPrimary
        contentView.addSubview(soundEffectsLabel)

        soundEffectsSwitch.onTintColor = ColorPalette.accentCyan
        soundEffectsSwitch.addTarget(self, action: #selector(soundEffectsToggled), for: .valueChanged)
        contentView.addSubview(soundEffectsSwitch)

        // Haptic feedback switch
        hapticsLabel.text = "Haptic Feedback"
        hapticsLabel.font = FontManager.bodyLarge()
        hapticsLabel.textColor = ColorPalette.textPrimary
        contentView.addSubview(hapticsLabel)

        hapticsSwitch.onTintColor = ColorPalette.accentCyan
        hapticsSwitch.addTarget(self, action: #selector(hapticsToggled), for: .valueChanged)
        contentView.addSubview(hapticsSwitch)

        // Statistics info container
        statsContainerView.backgroundColor = ColorPalette.cardBackground
        statsContainerView.layer.cornerRadius = 16
        statsContainerView.layer.borderWidth = 1
        statsContainerView.layer.borderColor = ColorPalette.gridCellBorder.cgColor
        contentView.addSubview(statsContainerView)

        streakLabel.font = FontManager.bodyMedium()
        streakLabel.textColor = ColorPalette.textSecondary
        streakLabel.numberOfLines = 0
        statsContainerView.addSubview(streakLabel)

        achievementsLabel.font = FontManager.bodyMedium()
        achievementsLabel.textColor = ColorPalette.textSecondary
        achievementsLabel.numberOfLines = 0
        statsContainerView.addSubview(achievementsLabel)

        pointsLabel.font = FontManager.bodyMedium()
        pointsLabel.textColor = ColorPalette.textSecondary
        pointsLabel.numberOfLines = 0
        statsContainerView.addSubview(pointsLabel)

        // About section
        aboutContainerView.backgroundColor = ColorPalette.cardBackground
        aboutContainerView.layer.cornerRadius = 16
        aboutContainerView.layer.borderWidth = 1
        aboutContainerView.layer.borderColor = ColorPalette.accentPurple.withAlphaComponent(0.3).cgColor
        contentView.addSubview(aboutContainerView)

        aboutTitleLabel.text = "About ShureMind"
        aboutTitleLabel.font = FontManager.headlineSmall()
        aboutTitleLabel.textColor = ColorPalette.accentPurple
        aboutContainerView.addSubview(aboutTitleLabel)

        aboutDescriptionLabel.text = "ShureMind is a cognitive training app designed to enhance your focus, memory, and mental agility through scientifically-backed exercises.\n\nFeatures:\n• Schulte Grid training with 8 unique shapes (🔷🌀⭕➕🔺⭐🌊🔶)\n• Picture Memory exercises\n• Daily challenges & achievements\n• Progress tracking & statistics\n• 5 beautiful themes\n• Haptic feedback & sound effects"
        aboutDescriptionLabel.font = FontManager.bodyMedium()
        aboutDescriptionLabel.textColor = ColorPalette.textSecondary
        aboutDescriptionLabel.numberOfLines = 0
        aboutContainerView.addSubview(aboutDescriptionLabel)

        feedbackButton.buttonTitle = "📧 Send Feedback"
        feedbackButton.buttonStyle = .secondary
        feedbackButton.addTarget(self, action: #selector(sendFeedback), for: .touchUpInside)
        aboutContainerView.addSubview(feedbackButton)

        versionInfoLabel.text = "Version 1.0.0\n© 2026 ShureMind"
        versionInfoLabel.font = FontManager.caption()
        versionInfoLabel.textColor = ColorPalette.textTertiary
        versionInfoLabel.textAlignment = .center
        versionInfoLabel.numberOfLines = 0
        aboutContainerView.addSubview(versionInfoLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        themeLabel.translatesAutoresizingMaskIntoConstraints = false
        themeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        soundEffectsLabel.translatesAutoresizingMaskIntoConstraints = false
        soundEffectsSwitch.translatesAutoresizingMaskIntoConstraints = false
        hapticsLabel.translatesAutoresizingMaskIntoConstraints = false
        hapticsSwitch.translatesAutoresizingMaskIntoConstraints = false
        statsContainerView.translatesAutoresizingMaskIntoConstraints = false
        streakLabel.translatesAutoresizingMaskIntoConstraints = false
        achievementsLabel.translatesAutoresizingMaskIntoConstraints = false
        pointsLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutContainerView.translatesAutoresizingMaskIntoConstraints = false
        aboutTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        feedbackButton.translatesAutoresizingMaskIntoConstraints = false
        versionInfoLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            themeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            themeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),

            themeSegmentedControl.topAnchor.constraint(equalTo: themeLabel.bottomAnchor, constant: 12),
            themeSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            themeSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            themeSegmentedControl.heightAnchor.constraint(equalToConstant: 40),

            soundEffectsLabel.topAnchor.constraint(equalTo: themeSegmentedControl.bottomAnchor, constant: 30),
            soundEffectsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),

            soundEffectsSwitch.centerYAnchor.constraint(equalTo: soundEffectsLabel.centerYAnchor),
            soundEffectsSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),

            hapticsLabel.topAnchor.constraint(equalTo: soundEffectsLabel.bottomAnchor, constant: 20),
            hapticsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),

            hapticsSwitch.centerYAnchor.constraint(equalTo: hapticsLabel.centerYAnchor),
            hapticsSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),

            statsContainerView.topAnchor.constraint(equalTo: hapticsLabel.bottomAnchor, constant: 30),
            statsContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            statsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),

            streakLabel.topAnchor.constraint(equalTo: statsContainerView.topAnchor, constant: 20),
            streakLabel.leadingAnchor.constraint(equalTo: statsContainerView.leadingAnchor, constant: 20),
            streakLabel.trailingAnchor.constraint(equalTo: statsContainerView.trailingAnchor, constant: -20),

            achievementsLabel.topAnchor.constraint(equalTo: streakLabel.bottomAnchor, constant: 15),
            achievementsLabel.leadingAnchor.constraint(equalTo: statsContainerView.leadingAnchor, constant: 20),
            achievementsLabel.trailingAnchor.constraint(equalTo: statsContainerView.trailingAnchor, constant: -20),

            pointsLabel.topAnchor.constraint(equalTo: achievementsLabel.bottomAnchor, constant: 15),
            pointsLabel.leadingAnchor.constraint(equalTo: statsContainerView.leadingAnchor, constant: 20),
            pointsLabel.trailingAnchor.constraint(equalTo: statsContainerView.trailingAnchor, constant: -20),
            pointsLabel.bottomAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: -20),

            // About section
            aboutContainerView.topAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: 30),
            aboutContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            aboutContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            aboutContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),

            aboutTitleLabel.topAnchor.constraint(equalTo: aboutContainerView.topAnchor, constant: 20),
            aboutTitleLabel.leadingAnchor.constraint(equalTo: aboutContainerView.leadingAnchor, constant: 20),
            aboutTitleLabel.trailingAnchor.constraint(equalTo: aboutContainerView.trailingAnchor, constant: -20),

            aboutDescriptionLabel.topAnchor.constraint(equalTo: aboutTitleLabel.bottomAnchor, constant: 15),
            aboutDescriptionLabel.leadingAnchor.constraint(equalTo: aboutContainerView.leadingAnchor, constant: 20),
            aboutDescriptionLabel.trailingAnchor.constraint(equalTo: aboutContainerView.trailingAnchor, constant: -20),

            feedbackButton.topAnchor.constraint(equalTo: aboutDescriptionLabel.bottomAnchor, constant: 20),
            feedbackButton.leadingAnchor.constraint(equalTo: aboutContainerView.leadingAnchor, constant: 20),
            feedbackButton.trailingAnchor.constraint(equalTo: aboutContainerView.trailingAnchor, constant: -20),
            feedbackButton.heightAnchor.constraint(equalToConstant: 50),

            versionInfoLabel.topAnchor.constraint(equalTo: feedbackButton.bottomAnchor, constant: 15),
            versionInfoLabel.leadingAnchor.constraint(equalTo: aboutContainerView.leadingAnchor, constant: 20),
            versionInfoLabel.trailingAnchor.constraint(equalTo: aboutContainerView.trailingAnchor, constant: -20),
            versionInfoLabel.bottomAnchor.constraint(equalTo: aboutContainerView.bottomAnchor, constant: -20),

            aboutContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }

    private func loadSettings() {
        // Load theme
        let currentTheme = ThemeManager.shared.getCurrentTheme()
        switch currentTheme {
        case .neonDark: themeSegmentedControl.selectedSegmentIndex = 0
        case .oceanBlue: themeSegmentedControl.selectedSegmentIndex = 1
        case .sunsetOrange: themeSegmentedControl.selectedSegmentIndex = 2
        case .forestGreen: themeSegmentedControl.selectedSegmentIndex = 3
        case .royalPurple: themeSegmentedControl.selectedSegmentIndex = 4
        }

        // Load switch states
        soundEffectsSwitch.isOn = SettingsManager.shared.soundEffectsEnabled
        hapticsSwitch.isOn = SettingsManager.shared.hapticsEnabled

        // Load statistics info
        updateStats()
    }

    private func updateStats() {
        let streak = StreakTracker.shared.getCurrentStreak()
        let longestStreak = StreakTracker.shared.getLongestStreak()
        streakLabel.text = "🔥 Training Streak: \(streak) days (Best: \(longestStreak) days)"

        let unlockedAchievements = AchievementSystem.shared.getUnlockedCount()
        let totalAchievements = AchievementSystem.shared.getTotalCount()
        achievementsLabel.text = "🏆 Achievements: \(unlockedAchievements)/\(totalAchievements)"

        let points = DailyChallengeManager.shared.getTotalPoints()
        pointsLabel.text = "⭐️ Total Points: \(points)"
    }

    @objc private func themeChanged() {
        let themes: [ThemeType] = [.neonDark, .oceanBlue, .sunsetOrange, .forestGreen, .royalPurple]
        let selectedTheme = themes[themeSegmentedControl.selectedSegmentIndex]
        ThemeManager.shared.setTheme(selectedTheme)
        HapticFeedbackEngine.shared.triggerSelection()
    }

    @objc private func soundEffectsToggled() {
        SettingsManager.shared.soundEffectsEnabled = soundEffectsSwitch.isOn
        HapticFeedbackEngine.shared.triggerSelection()
    }

    @objc private func hapticsToggled() {
        SettingsManager.shared.hapticsEnabled = hapticsSwitch.isOn
        if hapticsSwitch.isOn {
            HapticFeedbackEngine.shared.triggerSelection()
        }
    }

    @objc private func dismissView() {
        dismiss(animated: true)
    }

    @objc private func sendFeedback() {
        let email = "feedback@shuremind.app"
        let subject = "ShureMind Feedback"
        let body = "Please share your feedback or report any issues:\n\n"

        let mailtoString = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"

        if let mailtoURL = URL(string: mailtoString) {
            if UIApplication.shared.canOpenURL(mailtoURL) {
                UIApplication.shared.open(mailtoURL)
                HapticFeedbackEngine.shared.triggerSuccess()
            } else {
                showFeedbackAlert()
            }
        }
    }

    private func showFeedbackAlert() {
        let dialog = CustomDialogView(
            title: "Contact Us",
            message: "Please send your feedback to:\nfeedback@shuremind.app",
            buttons: [
                (title: "Copy Email", action: { [weak self] in
                    UIPasteboard.general.string = "feedback@shuremind.app"
                    HapticFeedbackEngine.shared.triggerSuccess()
                }),
                (title: "Close", action: {})
            ]
        )
        dialog.show(in: view)
    }
}
