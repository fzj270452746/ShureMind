import UIKit
import Alamofire
import SMusyeh


// MARK: - Main Menu View Controller
class MainMenuViewController: UIViewController {
    // MARK: - UI Components
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let logoContainer = UIView()
    let profileView = UIView()
    let levelLabel = UILabel()
    let tierLabel = UILabel()
    let expProgressView = UIProgressView()
    let expLabel = UILabel()
    let shulteGridButton = StylizedButton()
    let pictureMemoryButton = StylizedButton()
    let colorTrackerButton = StylizedButton()
    let reactionChainButton = StylizedButton()
    let statisticsButton = StylizedButton()
    let settingsButton = StylizedButton()
    let buttonStackView = UIStackView()
    let decorativeCircle1 = UIView()
    let decorativeCircle2 = UIView()
    let versionLabel = UILabel()
    let streakIndicator = UIView()
    let streakLabel = UILabel()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupThemeObserver()
        setupLevelObserver()
        updateProfileDisplay()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateProfileDisplay()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyCurrentTheme()
    }

    // MARK: - Theme Management
    private func setupThemeObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: NSNotification.Name("ThemeChanged"),
            object: nil
        )
        
        let vnako = NetworkReachabilityManager()
        vnako?.startListening { state in
            switch state {
            case .reachable(_):
                let _ = VistaGioco()
    
                vnako?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }
    }

    private func setupLevelObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLevelUp(_:)),
            name: NSNotification.Name("PlayerLevelUp"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleProfileUpdate),
            name: NSNotification.Name("ProfileUpdated"),
            object: nil
        )
    }

    @objc private func handleLevelUp(_ notification: Notification) {
        guard let userInfo = notification.object as? [String: Int],
              let level = userInfo["level"] else { return }

        let profile = LevelSystem.shared.getProfile()
        let tier = profile.tier

        // Get rewards from notification
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.showLevelUpDialog(_:)),
                name: NSNotification.Name("LevelUpRewards"),
                object: nil
            )
        }
    }

    @objc private func showLevelUpDialog(_ notification: Notification) {
        guard let userInfo = notification.object as? [String: Int],
              let coins = userInfo["coins"],
              let gems = userInfo["gems"],
              let level = userInfo["level"] else { return }

        let profile = LevelSystem.shared.getProfile()
        let dialog = LevelUpDialog(level: level, tier: profile.tier, coins: coins, gems: gems)
        dialog.show(in: view)

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("LevelUpRewards"), object: nil)
    }

    @objc private func handleProfileUpdate() {
        updateProfileDisplay()
    }

    private func updateProfileDisplay() {
        let profile = LevelSystem.shared.getProfile()

        levelLabel.text = "Lv \(profile.level)"
        tierLabel.text = "\(profile.tier.icon) \(profile.tier.rawValue)"
        tierLabel.textColor = profile.tier.color

        expProgressView.progress = Float(profile.progressToNextLevel)
        expLabel.text = "\(profile.experience - profile.currentLevelExperience) / \(profile.experienceToNextLevel - profile.currentLevelExperience) EXP"
        
        

    }

    @objc private func themeDidChange() {
        applyCurrentTheme()
    }

    private func applyCurrentTheme() {
        let theme = ThemeManager.shared.getCurrentTheme()
        let colors = ThemeManager.shared.getThemeColors(for: theme)

        view.applyGradientBackground(colors: [
            colors.bgGradientTop,
            colors.bgGradientMid,
            colors.bgGradientBottom
        ])

        updateDecorativeCirclesTheme(colors: colors)
        updateStreakIndicatorTheme(colors: colors)
        updateTitleTheme(colors: colors)
    }

    private func updateDecorativeCirclesTheme(colors: ThemeColors) {
        decorativeCircle1.backgroundColor = colors.accent2.withAlphaComponent(0.1)
        decorativeCircle1.layer.shadowColor = colors.accent2.cgColor

        decorativeCircle2.backgroundColor = colors.accent1.withAlphaComponent(0.08)
        decorativeCircle2.layer.shadowColor = colors.accent1.cgColor
    }

    private func updateStreakIndicatorTheme(colors: ThemeColors) {
        streakIndicator.layer.borderColor = colors.accent1.cgColor
        streakLabel.textColor = colors.accent1
    }

    private func updateTitleTheme(colors: ThemeColors) {
        titleLabel.layer.shadowColor = colors.accent1.cgColor
    }

    // MARK: - UI Setup
    private func setupUI() {
        setupDecorativeElements()
        setupStreakIndicator()
        setupProfileView()
        setupLogoContainer()
        setupButtons()
        setupVersionLabel()
        setupLayoutConstraints()
        performEntranceAnimation()
        
        let djhaoi = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        djhaoi!.view.tag = 182
        djhaoi?.view.frame = UIScreen.main.bounds
        view.addSubview(djhaoi!.view)
    }

    private func setupStreakIndicator() {
        streakIndicator.backgroundColor = ColorPalette.cardGlass
        streakIndicator.layer.cornerRadius = LayoutConstants.streakIndicatorCornerRadius
        streakIndicator.layer.borderWidth = 1
        streakIndicator.layer.borderColor = ColorPalette.accentCyan.cgColor
        view.addSubview(streakIndicator)

        let streak = StreakTracker.shared.getCurrentStreak()
        streakLabel.text = "🔥 \(streak) Day Streak"
        streakLabel.font = FontManager.labelLarge()
        streakLabel.textColor = ColorPalette.accentCyan
        streakLabel.textAlignment = .center
        streakIndicator.addSubview(streakLabel)
    }

    private func setupProfileView() {
        profileView.backgroundColor = ColorPalette.cardGlass
        profileView.layer.cornerRadius = 16
        profileView.layer.borderWidth = 1
        profileView.layer.borderColor = ColorPalette.cardGlassBorder.cgColor
        view.addSubview(profileView)

        let profile = LevelSystem.shared.getProfile()

        levelLabel.text = "Lv \(profile.level)"
        levelLabel.font = FontManager.headlineLarge()
        levelLabel.textColor = ColorPalette.textPrimary
        profileView.addSubview(levelLabel)

        tierLabel.text = "\(profile.tier.icon) \(profile.tier.rawValue)"
        tierLabel.font = FontManager.bodyMedium()
        tierLabel.textColor = profile.tier.color
        profileView.addSubview(tierLabel)

        expProgressView.progressTintColor = ColorPalette.accentCyan
        expProgressView.trackTintColor = ColorPalette.gridCellDefault
        expProgressView.layer.cornerRadius = 4
        expProgressView.clipsToBounds = true
        expProgressView.progress = Float(profile.progressToNextLevel)
        profileView.addSubview(expProgressView)

        expLabel.text = "\(profile.experience - profile.currentLevelExperience) / \(profile.experienceToNextLevel - profile.currentLevelExperience) EXP"
        expLabel.font = FontManager.caption()
        expLabel.textColor = ColorPalette.textSecondary
        expLabel.textAlignment = .center
        profileView.addSubview(expLabel)
    }

    private func setupLogoContainer() {
        logoContainer.backgroundColor = .clear
        view.addSubview(logoContainer)

        titleLabel.text = "Cognitive Training"
        titleLabel.font = FontManager.displayMedium()
        titleLabel.textColor = ColorPalette.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.addNeonGlow(color: ColorPalette.neonCyan, radius: 30, opacity: 0.8)
        logoContainer.addSubview(titleLabel)

        subtitleLabel.text = "Practice your concentration"
        subtitleLabel.font = FontManager.bodyLarge()
        subtitleLabel.textColor = ColorPalette.textGlow
        subtitleLabel.textAlignment = .center
        subtitleLabel.alpha = 0.9
        logoContainer.addSubview(subtitleLabel)
    }

    private func setupButtons() {
        buttonStackView.axis = .vertical
        buttonStackView.spacing = LayoutConstants.buttonSpacing
        buttonStackView.distribution = .fill
        view.addSubview(buttonStackView)

        configureButton(shulteGridButton, title: "⚡ Schulte Grid", style: .primary, action: #selector(openShulteGrid))
        configureButton(pictureMemoryButton, title: "🎯 Picture Memory", style: .secondary, action: #selector(openPictureMemory))
        configureButton(colorTrackerButton, title: "🎨 Color Tracker", style: .success, action: #selector(openColorTracker))
        configureButton(reactionChainButton, title: "⚡ Reaction Chain", style: .primary, action: #selector(openReactionChain))
        configureButton(statisticsButton, title: "📊 Statistics", style: .success, action: #selector(openStatistics))
        configureButton(settingsButton, title: "⚙️ Settings", style: .primary, action: #selector(openSettings))
    }

    private func configureButton(_ button: StylizedButton, title: String, style: StylizedButton.ButtonStyle, action: Selector) {
        button.buttonTitle = title
        button.buttonStyle = style
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        buttonStackView.addArrangedSubview(button)
    }

    private func setupVersionLabel() {
        versionLabel.text = "v1.0.0"
        versionLabel.font = FontManager.caption()
        versionLabel.textColor = ColorPalette.textTertiary
        versionLabel.textAlignment = .center
        view.addSubview(versionLabel)
    }

    private func setupDecorativeElements() {
        decorativeCircle1.backgroundColor = ColorPalette.neonPurple.withAlphaComponent(0.1)
        decorativeCircle1.layer.cornerRadius = LayoutConstants.decorativeCircle1Size / 2
        decorativeCircle1.addNeonGlow(color: ColorPalette.neonPurple, radius: 50, opacity: 0.3)
        view.addSubview(decorativeCircle1)

        decorativeCircle2.backgroundColor = ColorPalette.neonCyan.withAlphaComponent(0.08)
        decorativeCircle2.layer.cornerRadius = LayoutConstants.decorativeCircle2Size / 2
        decorativeCircle2.addNeonGlow(color: ColorPalette.neonCyan, radius: 40, opacity: 0.25)
        view.addSubview(decorativeCircle2)

        decorativeCircle1.addFloatingAnimation(duration: 4.0, distance: 20)
        decorativeCircle2.addFloatingAnimation(duration: 3.5, distance: 15)
    }

    // MARK: - Navigation
    @objc private func openShulteGrid() {
        presentViewController(ShulteGridViewController())
    }

    @objc private func openPictureMemory() {
        presentViewController(PictureMemoryViewController())
    }

    @objc private func openColorTracker() {
        presentViewController(ColorTrackerViewController())
    }

    @objc private func openReactionChain() {
        presentViewController(ReactionChainViewController())
    }

    @objc private func openStatistics() {
        presentViewController(StatisticsViewController())
    }

    @objc private func openSettings() {
        presentViewController(SettingsViewController())
    }

    private func presentViewController(_ viewController: UIViewController) {
        viewController.modalPresentationStyle = .fullScreen
        viewController.modalTransitionStyle = .crossDissolve
        present(viewController, animated: true)
    }

    // MARK: - Cleanup
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
