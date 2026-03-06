import UIKit

// MARK: - Reaction Chain Game Mode
class ReactionChainViewController: UIViewController {
    // MARK: - Game State
    private var score: Int = 0
    private var combo: Int = 0
    private var maxCombo: Int = 0
    private var missCount: Int = 0
    private var isGameActive: Bool = false
    private var difficulty: Int = 0
    private var targetSpeed: TimeInterval = 1.5
    private var targetLifetime: TimeInterval = 2.0
    private var gameTimer: Timer?
    private var startTime: Date?
    private var currentTarget: TargetView?

    // MARK: - UI Components
    private let headerView = UIView()
    private let backButton = UIButton()
    private let scoreLabel = UILabel()
    private let comboLabel = UILabel()
    private let instructionLabel = UILabel()
    private let gameAreaView = UIView()
    private let difficultySelector = UISegmentedControl(items: ["Easy", "Medium", "Hard", "Extreme"])
    private let startButton = StylizedButton()
    private let statsView = UIView()
    private let missLabel = UILabel()
    private let maxComboLabel = UILabel()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupThemeObserver()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyCurrentTheme()
    }

    // MARK: - Theme
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
        view.applyGradientBackground(colors: [colors.bgGradientTop, colors.bgGradientMid])
        scoreLabel.textColor = colors.accent1
        comboLabel.textColor = colors.accent2
        difficultySelector.selectedSegmentTintColor = colors.accent2
    }

    // MARK: - UI Setup
    private func setupUI() {
        // Header
        headerView.backgroundColor = .clear
        view.addSubview(headerView)

        backButton.setTitle("←", for: .normal)
        backButton.titleLabel?.font = FontManager.displaySmall()
        backButton.setTitleColor(ColorPalette.textPrimary, for: .normal)
        backButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        headerView.addSubview(backButton)

        scoreLabel.text = "Score: 0"
        scoreLabel.font = FontManager.headlineLarge()
        scoreLabel.textColor = ColorPalette.accentCyan
        scoreLabel.textAlignment = .center
        headerView.addSubview(scoreLabel)

        comboLabel.text = "Combo: 0"
        comboLabel.font = FontManager.headlineMedium()
        comboLabel.textColor = ColorPalette.neonPink
        comboLabel.textAlignment = .center
        view.addSubview(comboLabel)

        // Instruction
        instructionLabel.text = "Tap the targets quickly!"
        instructionLabel.font = FontManager.bodyLarge()
        instructionLabel.textColor = ColorPalette.textPrimary
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 2
        view.addSubview(instructionLabel)

        // Stats view
        statsView.backgroundColor = ColorPalette.cardGlass
        statsView.layer.cornerRadius = 16
        statsView.layer.borderWidth = 1
        statsView.layer.borderColor = ColorPalette.cardGlassBorder.cgColor
        statsView.isHidden = true
        view.addSubview(statsView)

        missLabel.text = "Misses: 0"
        missLabel.font = FontManager.bodyMedium()
        missLabel.textColor = ColorPalette.textSecondary
        missLabel.textAlignment = .center
        statsView.addSubview(missLabel)

        maxComboLabel.text = "Max Combo: 0"
        maxComboLabel.font = FontManager.bodyMedium()
        maxComboLabel.textColor = ColorPalette.textSecondary
        maxComboLabel.textAlignment = .center
        statsView.addSubview(maxComboLabel)

        // Difficulty selector
        difficultySelector.selectedSegmentIndex = 0
        difficultySelector.backgroundColor = ColorPalette.cardBackground
        difficultySelector.selectedSegmentTintColor = ColorPalette.accentPurple
        difficultySelector.setTitleTextAttributes([.foregroundColor: ColorPalette.textPrimary], for: .normal)
        difficultySelector.setTitleTextAttributes([.foregroundColor: ColorPalette.textPrimary], for: .selected)
        difficultySelector.addTarget(self, action: #selector(difficultyChanged), for: .valueChanged)
        view.addSubview(difficultySelector)

        // Game area
        gameAreaView.backgroundColor = ColorPalette.cardGlass.withAlphaComponent(0.3)
        gameAreaView.layer.cornerRadius = 20
        gameAreaView.layer.borderWidth = 2
        gameAreaView.layer.borderColor = ColorPalette.cardGlassBorder.cgColor
        view.addSubview(gameAreaView)

        // Start button
        startButton.buttonTitle = "Start Training"
        startButton.buttonStyle = .primary
        startButton.addTarget(self, action: #selector(startGame), for: .touchUpInside)
        view.addSubview(startButton)

        setupConstraints()
    }

    private func setupConstraints() {
        [headerView, backButton, scoreLabel, comboLabel, instructionLabel,
         statsView, missLabel, maxComboLabel, difficultySelector,
         gameAreaView, startButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            scoreLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            scoreLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            comboLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10),
            comboLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            instructionLabel.topAnchor.constraint(equalTo: comboLabel.bottomAnchor, constant: 20),
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),

            statsView.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 15),
            statsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statsView.widthAnchor.constraint(equalToConstant: 250),
            statsView.heightAnchor.constraint(equalToConstant: 60),

            missLabel.leadingAnchor.constraint(equalTo: statsView.leadingAnchor, constant: 20),
            missLabel.centerYAnchor.constraint(equalTo: statsView.centerYAnchor),

            maxComboLabel.trailingAnchor.constraint(equalTo: statsView.trailingAnchor, constant: -20),
            maxComboLabel.centerYAnchor.constraint(equalTo: statsView.centerYAnchor),

            difficultySelector.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 20),
            difficultySelector.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            difficultySelector.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            difficultySelector.heightAnchor.constraint(equalToConstant: 40),

            gameAreaView.topAnchor.constraint(equalTo: difficultySelector.bottomAnchor, constant: 30),
            gameAreaView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gameAreaView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            gameAreaView.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -30),

            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            startButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    // MARK: - Game Logic
    @objc private func difficultyChanged() {
        difficulty = difficultySelector.selectedSegmentIndex
        switch difficulty {
        case 0: // Easy
            targetSpeed = 1.5
            targetLifetime = 2.5
        case 1: // Medium
            targetSpeed = 1.0
            targetLifetime = 2.0
        case 2: // Hard
            targetSpeed = 0.7
            targetLifetime = 1.5
        case 3: // Extreme
            targetSpeed = 0.5
            targetLifetime = 1.0
        default:
            break
        }
    }

    @objc private func startGame() {
        isGameActive = true
        score = 0
        combo = 0
        maxCombo = 0
        missCount = 0
        startTime = Date()

        scoreLabel.text = "Score: 0"
        comboLabel.text = "Combo: 0"
        missLabel.text = "Misses: 0"
        maxComboLabel.text = "Max Combo: 0"

        startButton.isHidden = true
        difficultySelector.isHidden = true
        instructionLabel.isHidden = true
        statsView.isHidden = false

        spawnTarget()

        HapticFeedbackEngine.shared.triggerSuccess()
    }

    private func spawnTarget() {
        guard isGameActive else { return }

        // Remove old target if exists
        currentTarget?.removeFromSuperview()

        // Calculate random position
        let margin: CGFloat = 60
        let maxX = gameAreaView.bounds.width - margin
        let maxY = gameAreaView.bounds.height - margin

        let randomX = CGFloat.random(in: margin...maxX)
        let randomY = CGFloat.random(in: margin...maxY)

        // Create new target
        let target = TargetView(lifetime: targetLifetime)
        target.center = CGPoint(x: randomX, y: randomY)
        target.addTarget(self, action: #selector(targetTapped(_:)), for: .touchUpInside)
        target.onExpired = { [weak self] in
            self?.targetMissed()
        }

        gameAreaView.addSubview(target)
        currentTarget = target
        target.startLifetime()

        // Spawn next target after delay
        let spawnDelay = targetSpeed * (1.0 - Double(combo) * 0.01) // Speed up with combo
        gameTimer = Timer.scheduledTimer(withTimeInterval: max(0.3, spawnDelay), repeats: false) { [weak self] _ in
            self?.spawnTarget()
        }
    }

    @objc private func targetTapped(_ sender: TargetView) {
        guard isGameActive else { return }

        sender.hit()

        // Calculate points based on remaining lifetime
        let timeBonus = Int(sender.remainingLifetime * 10)
        let comboBonus = combo * 2
        let points = 10 + timeBonus + comboBonus

        score += points
        combo += 1
        maxCombo = max(maxCombo, combo)

        scoreLabel.text = "Score: \(score)"
        updateComboLabel()
        maxComboLabel.text = "Max Combo: \(maxCombo)"

        HapticFeedbackEngine.shared.triggerSuccess()

        // Show floating score
        showFloatingScore(points, at: sender.center)
    }

    private func targetMissed() {
        guard isGameActive else { return }

        missCount += 1
        combo = 0

        missLabel.text = "Misses: \(missCount)"
        updateComboLabel()

        HapticFeedbackEngine.shared.triggerError()

        // End game after 5 misses
        if missCount >= 5 {
            endGame()
        }
    }

    private func updateComboLabel() {
        comboLabel.text = "Combo: \(combo)"

        if combo > 0 {
            let scale: CGFloat = 1.0 + CGFloat(min(combo, 20)) * 0.02
            UIView.animate(withDuration: 0.2) {
                self.comboLabel.transform = CGAffineTransform(scaleX: scale, y: scale)
            }

            // Change color based on combo
            if combo >= 50 {
                comboLabel.textColor = ColorPalette.neonOrange
            } else if combo >= 30 {
                comboLabel.textColor = ColorPalette.neonPurple
            } else if combo >= 10 {
                comboLabel.textColor = ColorPalette.neonCyan
            } else {
                comboLabel.textColor = ColorPalette.neonPink
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.comboLabel.transform = .identity
                self.comboLabel.textColor = ColorPalette.textSecondary
            }
        }
    }

    private func showFloatingScore(_ points: Int, at position: CGPoint) {
        let label = UILabel()
        label.text = "+\(points)"
        label.font = FontManager.headlineMedium()
        label.textColor = ColorPalette.successGlow
        label.textAlignment = .center
        label.frame = CGRect(x: position.x - 50, y: position.y - 20, width: 100, height: 40)
        gameAreaView.addSubview(label)

        UIView.animate(withDuration: 1.0, animations: {
            label.alpha = 0
            label.frame.origin.y -= 50
        }) { _ in
            label.removeFromSuperview()
        }
    }

    private func endGame() {
        isGameActive = false
        gameTimer?.invalidate()
        currentTarget?.removeFromSuperview()

        guard let startTime = startTime else { return }
        let duration = Date().timeIntervalSince(startTime)

        // Record training
        StreakTracker.shared.recordTrainingToday()

        // Calculate experience
        let baseExp = 40
        let comboMultiplier = Double(maxCombo) / 50.0
        let accuracyMultiplier = Double(score) / Double(max(score + missCount * 20, 1))
        let performanceMultiplier = (comboMultiplier + accuracyMultiplier) / 2.0

        let exp = LevelSystem.shared.calculateExperienceReward(
            baseExp: baseExp,
            performanceMultiplier: max(0.5, performanceMultiplier),
            perfectBonus: (missCount == 0),
            speedBonus: (maxCombo >= 30)
        )

        LevelSystem.shared.addExperience(exp)
        LevelSystem.shared.addCoins(score / 2)
        LevelSystem.shared.recordGamePlayed(mode: "ReactionChain", score: Double(maxCombo), duration: duration)

        // Update achievements
        AchievementSystem.shared.incrementAchievement(id: "first_game")
        AchievementSystem.shared.incrementAchievement(id: "ten_games")
        AchievementSystem.shared.incrementAchievement(id: "fifty_games")

        if maxCombo >= 20 {
            AchievementSystem.shared.updateAchievement(id: "speed_demon", value: 1)
        }

        let message = """
        Score: \(score)
        Max Combo: \(maxCombo)
        Misses: \(missCount)

        Rewards: +\(exp) EXP, +\(score/2) Coins
        """

        let dialog = CustomDialogView(title: "Training Complete", message: message, buttons: [
            (title: "Continue", action: { [weak self] in
                self?.resetGame()
            }),
            (title: "Exit", action: { [weak self] in
                self?.dismissView()
            })
        ])
        dialog.show(in: view)

        HapticFeedbackEngine.shared.triggerSuccess()
    }

    private func resetGame() {
        startButton.isHidden = false
        difficultySelector.isHidden = false
        instructionLabel.isHidden = false
        statsView.isHidden = true
        comboLabel.transform = .identity
    }

    @objc private func dismissView() {
        gameTimer?.invalidate()
        dismiss(animated: true)
    }

    deinit {
        gameTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Target View
class TargetView: UIButton {
    private var lifetime: TimeInterval
    private(set) var remainingLifetime: TimeInterval
    private var lifetimeTimer: Timer?
    private let progressLayer = CAShapeLayer()
    var onExpired: (() -> Void)?

    init(lifetime: TimeInterval) {
        self.lifetime = lifetime
        self.remainingLifetime = lifetime
        super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        setupAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupAppearance() {
        backgroundColor = ColorPalette.neonCyan
        layer.cornerRadius = 25
        layer.shadowColor = ColorPalette.neonCyan.cgColor
        layer.shadowOffset = .zero
        layer.shadowRadius = 15
        layer.shadowOpacity = 0.8

        // Progress ring
        let circularPath = UIBezierPath(
            arcCenter: CGPoint(x: 25, y: 25),
            radius: 22,
            startAngle: -.pi / 2,
            endAngle: 3 * .pi / 2,
            clockwise: true
        )

        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = UIColor.white.cgColor
        progressLayer.lineWidth = 3
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 1.0
        layer.addSublayer(progressLayer)

        // Pulse animation
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.1
        pulseAnimation.duration = 0.5
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        layer.add(pulseAnimation, forKey: "pulse")
    }

    func startLifetime() {
        lifetimeTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.remainingLifetime -= 0.05

            let progress = self.remainingLifetime / self.lifetime
            self.progressLayer.strokeEnd = progress

            // Change color as time runs out
            if progress < 0.3 {
                self.backgroundColor = ColorPalette.errorPulse
                self.layer.shadowColor = ColorPalette.errorPulse.cgColor
            } else if progress < 0.6 {
                self.backgroundColor = ColorPalette.neonOrange
                self.layer.shadowColor = ColorPalette.neonOrange.cgColor
            }

            if self.remainingLifetime <= 0 {
                self.expire()
            }
        }
    }

    func hit() {
        lifetimeTimer?.invalidate()

        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }

    private func expire() {
        lifetimeTimer?.invalidate()
        onExpired?()

        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }

    deinit {
        lifetimeTimer?.invalidate()
    }
}
