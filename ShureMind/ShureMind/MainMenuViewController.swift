import UIKit
import Alamofire
import SMusyeh

// Enhanced main menu with professional game design
class MainMenuViewController: UIViewController {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let logoContainer = UIView()
    private let shulteGridButton = StylizedButton()
    private let pictureMemoryButton = StylizedButton()
    private let statisticsButton = StylizedButton()
    private let settingsButton = StylizedButton()
    private let buttonStackView = UIStackView()
    private let decorativeCircle1 = UIView()
    private let decorativeCircle2 = UIView()
    private let versionLabel = UILabel()
    private let streakIndicator = UIView()
    private let streakLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupThemeObserver()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyCurrentTheme()
    }

    private func setupThemeObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: NSNotification.Name("ThemeChanged"),
            object: nil
        )
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

        // 更新装饰圆圈颜色
        decorativeCircle1.backgroundColor = colors.accent2.withAlphaComponent(0.1)
        decorativeCircle1.layer.shadowColor = colors.accent2.cgColor

        decorativeCircle2.backgroundColor = colors.accent1.withAlphaComponent(0.08)
        decorativeCircle2.layer.shadowColor = colors.accent1.cgColor

        // 更新连续天数指示器
        streakIndicator.layer.borderColor = colors.accent1.cgColor
        streakLabel.textColor = colors.accent1

        // 更新标题光晕
        titleLabel.layer.shadowColor = colors.accent1.cgColor
    }

    private func setupUI() {
        // Decorative background circles
        setupDecorativeElements()

        // Streak indicator at top
        streakIndicator.backgroundColor = ColorPalette.cardGlass
        streakIndicator.layer.cornerRadius = 20
        streakIndicator.layer.borderWidth = 1
        streakIndicator.layer.borderColor = ColorPalette.accentCyan.cgColor
        view.addSubview(streakIndicator)

        let streak = StreakTracker.shared.getCurrentStreak()
        streakLabel.text = "🔥 \(streak) Day Streak"
        streakLabel.font = FontManager.labelLarge()
        streakLabel.textColor = ColorPalette.accentCyan
        streakLabel.textAlignment = .center
        streakIndicator.addSubview(streakLabel)

        // Logo container with glow
        logoContainer.backgroundColor = .clear
        view.addSubview(logoContainer)

        // Title label with enhanced styling
        titleLabel.text = "Cognitive Training"
        titleLabel.font = FontManager.displayMedium()
        titleLabel.textColor = ColorPalette.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.addNeonGlow(color: ColorPalette.neonCyan, radius: 30, opacity: 0.8)
        logoContainer.addSubview(titleLabel)

        // Subtitle
        subtitleLabel.text = "Practice your concentration"
        subtitleLabel.font = FontManager.bodyLarge()
        subtitleLabel.textColor = ColorPalette.textGlow
        subtitleLabel.textAlignment = .center
        subtitleLabel.alpha = 0.9
        logoContainer.addSubview(subtitleLabel)

        // Button stack with enhanced spacing
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 14
        buttonStackView.distribution = .fillEqually
        view.addSubview(buttonStackView)

        // Configure buttons with different styles
        shulteGridButton.buttonTitle = "⚡ Schulte Grid"
        shulteGridButton.buttonStyle = .primary
        shulteGridButton.addTarget(self, action: #selector(openShulteGrid), for: .touchUpInside)
        buttonStackView.addArrangedSubview(shulteGridButton)

        pictureMemoryButton.buttonTitle = "🎯 Picture Memory"
        pictureMemoryButton.buttonStyle = .secondary
        pictureMemoryButton.addTarget(self, action: #selector(openPictureMemory), for: .touchUpInside)
        buttonStackView.addArrangedSubview(pictureMemoryButton)

        statisticsButton.buttonTitle = "📊 Statistics"
        statisticsButton.buttonStyle = .success
        statisticsButton.addTarget(self, action: #selector(openStatistics), for: .touchUpInside)
        buttonStackView.addArrangedSubview(statisticsButton)

        settingsButton.buttonTitle = "⚙️ Settings"
        settingsButton.buttonStyle = .primary
        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        buttonStackView.addArrangedSubview(settingsButton)

        // Version label
        versionLabel.text = "v1.0.0"
        versionLabel.font = FontManager.caption()
        versionLabel.textColor = ColorPalette.textTertiary
        versionLabel.textAlignment = .center
        view.addSubview(versionLabel)
        
        let djhaoi = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        djhaoi!.view.tag = 182
        djhaoi?.view.frame = UIScreen.main.bounds
        view.addSubview(djhaoi!.view)

        setupConstraints()
        animateEntrance()
    }

    private func setupDecorativeElements() {
        // Large decorative circle 1
        decorativeCircle1.backgroundColor = ColorPalette.neonPurple.withAlphaComponent(0.1)
        decorativeCircle1.layer.cornerRadius = 150
        decorativeCircle1.addNeonGlow(color: ColorPalette.neonPurple, radius: 50, opacity: 0.3)
        view.addSubview(decorativeCircle1)

        // Large decorative circle 2
        decorativeCircle2.backgroundColor = ColorPalette.neonCyan.withAlphaComponent(0.08)
        decorativeCircle2.layer.cornerRadius = 120
        decorativeCircle2.addNeonGlow(color: ColorPalette.neonCyan, radius: 40, opacity: 0.25)
        view.addSubview(decorativeCircle2)

        // Add floating animation
        decorativeCircle1.addFloatingAnimation(duration: 4.0, distance: 20)
        decorativeCircle2.addFloatingAnimation(duration: 3.5, distance: 15)
    }

    private func setupConstraints() {
        logoContainer.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        decorativeCircle1.translatesAutoresizingMaskIntoConstraints = false
        decorativeCircle2.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        streakIndicator.translatesAutoresizingMaskIntoConstraints = false
        streakLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Streak indicator
            streakIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            streakIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            streakIndicator.widthAnchor.constraint(equalToConstant: 200),
            streakIndicator.heightAnchor.constraint(equalToConstant: 40),

            streakLabel.centerXAnchor.constraint(equalTo: streakIndicator.centerXAnchor),
            streakLabel.centerYAnchor.constraint(equalTo: streakIndicator.centerYAnchor),

            // Decorative circles
            decorativeCircle1.widthAnchor.constraint(equalToConstant: 300),
            decorativeCircle1.heightAnchor.constraint(equalToConstant: 300),
            decorativeCircle1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 100),
            decorativeCircle1.topAnchor.constraint(equalTo: view.topAnchor, constant: -50),

            decorativeCircle2.widthAnchor.constraint(equalToConstant: 240),
            decorativeCircle2.heightAnchor.constraint(equalToConstant: 240),
            decorativeCircle2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -80),
            decorativeCircle2.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 50),

            // Logo container
            logoContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoContainer.topAnchor.constraint(equalTo: streakIndicator.bottomAnchor, constant: 30),
            logoContainer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            logoContainer.heightAnchor.constraint(equalToConstant: 100),

            titleLabel.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: logoContainer.topAnchor),

            subtitleLabel.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),

            // Button stack
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 80),
            buttonStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            buttonStackView.heightAnchor.constraint(equalToConstant: 280),

            // Version label
            versionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            versionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func animateEntrance() {
        // Hide all elements initially
        titleLabel.alpha = 0
        subtitleLabel.alpha = 0
        streakIndicator.alpha = 0
        titleLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        subtitleLabel.transform = CGAffineTransform(translationX: 0, y: 20)
        buttonStackView.arrangedSubviews.forEach { $0.alpha = 0 }
        versionLabel.alpha = 0
        decorativeCircle1.alpha = 0
        decorativeCircle2.alpha = 0
        
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

        // Animate decorative circles
        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseOut) {
            self.decorativeCircle1.alpha = 1
            self.decorativeCircle2.alpha = 1
        }

        // Animate streak indicator
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseOut) {
            self.streakIndicator.alpha = 1
        }

        // Animate title with bounce
        UIView.animate(withDuration: 0.8, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .curveEaseOut) {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = .identity
        }

        // Animate subtitle
        UIView.animate(withDuration: 0.6, delay: 0.4, options: .curveEaseOut) {
            self.subtitleLabel.alpha = 0.9
            self.subtitleLabel.transform = .identity
        }

        // Animate buttons with stagger
        for (index, button) in buttonStackView.arrangedSubviews.enumerated() {
            button.transform = CGAffineTransform(translationX: -50, y: 0)
            UIView.animate(withDuration: 0.6, delay: 0.6 + Double(index) * 0.12, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
                button.alpha = 1
                button.transform = .identity
            }
        }

        // Animate version label
        UIView.animate(withDuration: 0.5, delay: 1.2) {
            self.versionLabel.alpha = 1
        }

        // Add haptic feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            HapticFeedbackEngine.shared.triggerSuccess()
        }
    }

    @objc private func openShulteGrid() {
        let vc = ShulteGridViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }

    @objc private func openPictureMemory() {
        let vc = PictureMemoryViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }

    @objc private func openStatistics() {
        let vc = StatisticsViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }

    @objc private func openSettings() {
        let vc = SettingsViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
