import UIKit

// MARK: - Color Tracker Game Mode
class ColorTrackerViewController: UIViewController {
    // MARK: - Game State
    private var gridSize: Int = 4
    private var targetColor: UIColor = .red
    private var colorCells: [ColorCell] = []
    private var score: Int = 0
    private var round: Int = 0
    private var maxRounds: Int = 10
    private var isGameActive: Bool = false
    private var changeSpeed: TimeInterval = 2.0
    private var colorChangeTimer: Timer?
    private var gameTimer: Timer?
    private var startTime: Date?

    // MARK: - UI Components
    private let headerView = UIView()
    private let backButton = UIButton()
    private let scoreLabel = UILabel()
    private let roundLabel = UILabel()
    private let instructionLabel = UILabel()
    private let targetColorView = UIView()
    private let targetColorLabel = UILabel()
    private let gridContainerView = UIView()
    private let difficultySelector = UISegmentedControl(items: ["Easy", "Medium", "Hard", "Extreme"])
    private let startButton = StylizedButton()

    // MARK: - Color Palette
    private let gameColors: [UIColor] = [
        UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0),   // Red
        UIColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0),   // Green
        UIColor(red: 0.2, green: 0.5, blue: 1.0, alpha: 1.0),   // Blue
        UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0),   // Yellow
        UIColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0),   // Orange
        UIColor(red: 0.8, green: 0.2, blue: 1.0, alpha: 1.0),   // Purple
        UIColor(red: 0.0, green: 0.9, blue: 0.9, alpha: 1.0),   // Cyan
        UIColor(red: 1.0, green: 0.4, blue: 0.7, alpha: 1.0)    // Pink
    ]

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

        roundLabel.text = "Round: 0/10"
        roundLabel.font = FontManager.bodyLarge()
        roundLabel.textColor = ColorPalette.textSecondary
        roundLabel.textAlignment = .center
        view.addSubview(roundLabel)

        // Instruction
        instructionLabel.text = "Track the target color blocks"
        instructionLabel.font = FontManager.bodyLarge()
        instructionLabel.textColor = ColorPalette.textPrimary
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 2
        view.addSubview(instructionLabel)

        // Target color display
        targetColorView.layer.cornerRadius = 30
        targetColorView.layer.borderWidth = 3
        targetColorView.layer.borderColor = ColorPalette.accentCyan.cgColor
        view.addSubview(targetColorView)

        targetColorLabel.text = "Target Color"
        targetColorLabel.font = FontManager.caption()
        targetColorLabel.textColor = ColorPalette.textSecondary
        targetColorLabel.textAlignment = .center
        view.addSubview(targetColorLabel)

        // Difficulty selector
        difficultySelector.selectedSegmentIndex = 0
        difficultySelector.backgroundColor = ColorPalette.cardBackground
        difficultySelector.selectedSegmentTintColor = ColorPalette.accentPurple
        difficultySelector.setTitleTextAttributes([.foregroundColor: ColorPalette.textPrimary], for: .normal)
        difficultySelector.setTitleTextAttributes([.foregroundColor: ColorPalette.textPrimary], for: .selected)
        difficultySelector.addTarget(self, action: #selector(difficultyChanged), for: .valueChanged)
        view.addSubview(difficultySelector)

        // Grid container
        gridContainerView.backgroundColor = .clear
        view.addSubview(gridContainerView)

        // Start button
        startButton.buttonTitle = "Start Training"
        startButton.buttonStyle = .primary
        startButton.addTarget(self, action: #selector(startGame), for: .touchUpInside)
        view.addSubview(startButton)

        setupConstraints()
    }

    private func setupConstraints() {
        [headerView, backButton, scoreLabel, roundLabel, instructionLabel,
         targetColorView, targetColorLabel, difficultySelector,
         gridContainerView, startButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            scoreLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            scoreLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            roundLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8),
            roundLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            instructionLabel.topAnchor.constraint(equalTo: roundLabel.bottomAnchor, constant: 12),
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),

            targetColorView.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 12),
            targetColorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            targetColorView.widthAnchor.constraint(equalToConstant: 50),
            targetColorView.heightAnchor.constraint(equalToConstant: 50),

            targetColorLabel.topAnchor.constraint(equalTo: targetColorView.bottomAnchor, constant: 6),
            targetColorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            difficultySelector.topAnchor.constraint(equalTo: targetColorLabel.bottomAnchor, constant: 12),
            difficultySelector.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            difficultySelector.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            difficultySelector.heightAnchor.constraint(equalToConstant: 40),

            gridContainerView.topAnchor.constraint(equalTo: difficultySelector.bottomAnchor, constant: 20),
            gridContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gridContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            gridContainerView.heightAnchor.constraint(equalTo: gridContainerView.widthAnchor),

            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            startButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    // MARK: - Game Logic
    @objc private func difficultyChanged() {
        switch difficultySelector.selectedSegmentIndex {
        case 0: // Easy
            gridSize = 4
            changeSpeed = 2.5
            maxRounds = 8
        case 1: // Medium
            gridSize = 5
            changeSpeed = 2.0
            maxRounds = 10
        case 2: // Hard
            gridSize = 6
            changeSpeed = 1.5
            maxRounds = 12
        case 3: // Extreme
            gridSize = 7
            changeSpeed = 1.0
            maxRounds = 15
        default:
            break
        }
    }

    @objc private func startGame() {
        isGameActive = true
        score = 0
        round = 0
        startTime = Date()

        scoreLabel.text = "Score: 0"
        roundLabel.text = "Round: 0/\(maxRounds)"

        startButton.isHidden = true
        difficultySelector.isEnabled = false

        generateGrid()
        startNewRound()

        HapticFeedbackEngine.shared.triggerSuccess()
    }

    private func generateGrid() {
        colorCells.forEach { $0.removeFromSuperview() }
        colorCells.removeAll()

        let spacing: CGFloat = 8
        let cellSize = (view.bounds.width * 0.9 - spacing * CGFloat(gridSize + 1)) / CGFloat(gridSize)

        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let cell = ColorCell(size: cellSize)
                cell.tag = row * gridSize + col
                cell.addTarget(self, action: #selector(cellTapped(_:)), for: .touchUpInside)

                gridContainerView.addSubview(cell)
                cell.translatesAutoresizingMaskIntoConstraints = false

                NSLayoutConstraint.activate([
                    cell.widthAnchor.constraint(equalToConstant: cellSize),
                    cell.heightAnchor.constraint(equalToConstant: cellSize),
                    cell.leadingAnchor.constraint(
                        equalTo: gridContainerView.leadingAnchor,
                        constant: spacing + CGFloat(col) * (cellSize + spacing)
                    ),
                    cell.topAnchor.constraint(
                        equalTo: gridContainerView.topAnchor,
                        constant: spacing + CGFloat(row) * (cellSize + spacing)
                    )
                ])

                colorCells.append(cell)
            }
        }
    }

    private func startNewRound() {
        round += 1
        roundLabel.text = "Round: \(round)/\(maxRounds)"

        // Select random target color
        targetColor = gameColors.randomElement()!
        targetColorView.backgroundColor = targetColor

        // Assign random colors to cells
        colorCells.forEach { cell in
            cell.currentColor = gameColors.randomElement()!
            cell.isTarget = (cell.currentColor == targetColor)
        }

        // Start color changing
        startColorChanging()
    }

    private func startColorChanging() {
        colorChangeTimer?.invalidate()
        colorChangeTimer = Timer.scheduledTimer(withTimeInterval: changeSpeed, repeats: true) { [weak self] _ in
            self?.changeColors()
        }
    }

    private func changeColors() {
        colorCells.forEach { cell in
            let newColor = gameColors.randomElement()!
            cell.animateColorChange(to: newColor)
            cell.isTarget = (newColor == targetColor)
        }
    }

    @objc private func cellTapped(_ sender: ColorCell) {
        guard isGameActive else { return }

        if sender.isTarget {
            // Correct!
            score += 10
            scoreLabel.text = "Score: \(score)"
            sender.showCorrectFeedback()
            HapticFeedbackEngine.shared.triggerSuccess()

            // Next round
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if self.round >= self.maxRounds {
                    self.endGame()
                } else {
                    self.startNewRound()
                }
            }
        } else {
            // Wrong!
            score = max(0, score - 5)
            scoreLabel.text = "Score: \(score)"
            sender.showWrongFeedback()
            HapticFeedbackEngine.shared.triggerError()
        }
    }

    private func endGame() {
        isGameActive = false
        colorChangeTimer?.invalidate()

        guard let startTime = startTime else { return }
        let duration = Date().timeIntervalSince(startTime)

        // Record training
        StreakTracker.shared.recordTrainingToday()

        // Calculate experience
        let baseExp = 30
        let performanceMultiplier = Double(score) / Double(maxRounds * 10)
        let perfectBonus = (score == maxRounds * 10)
        let exp = LevelSystem.shared.calculateExperienceReward(
            baseExp: baseExp,
            performanceMultiplier: max(0.5, performanceMultiplier),
            perfectBonus: perfectBonus
        )

        LevelSystem.shared.addExperience(exp)
        LevelSystem.shared.addCoins(score)
        LevelSystem.shared.recordGamePlayed(mode: "ColorTracker", score: Double(score), duration: duration)

        // Update achievements
        AchievementSystem.shared.incrementAchievement(id: "first_game")
        AchievementSystem.shared.incrementAchievement(id: "ten_games")
        AchievementSystem.shared.incrementAchievement(id: "fifty_games")

        let message = perfectBonus ?
            "Perfect!\nScore: \(score)\nRewards: +\(exp) EXP, +\(score) Coins" :
            "Complete!\nScore: \(score)\nRewards: +\(exp) EXP, +\(score) Coins"

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
        difficultySelector.isEnabled = true
        colorCells.forEach { $0.removeFromSuperview() }
        colorCells.removeAll()
    }

    @objc private func dismissView() {
        colorChangeTimer?.invalidate()
        dismiss(animated: true)
    }

    deinit {
        colorChangeTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Color Cell
class ColorCell: UIButton {
    var currentColor: UIColor = .gray {
        didSet {
            backgroundColor = currentColor
        }
    }

    var isTarget: Bool = false

    init(size: CGFloat) {
        super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        setupAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAppearance()
    }

    private func setupAppearance() {
        layer.cornerRadius = 12
        layer.borderWidth = 2
        layer.borderColor = ColorPalette.gridCellBorder.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.3
    }

    func animateColorChange(to color: UIColor) {
        UIView.animate(withDuration: 0.3) {
            self.currentColor = color
        }
    }

    func showCorrectFeedback() {
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.layer.borderColor = ColorPalette.successGlow.cgColor
            self.layer.borderWidth = 4
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity
                self.layer.borderWidth = 2
                self.layer.borderColor = ColorPalette.gridCellBorder.cgColor
            }
        }
    }

    func showWrongFeedback() {
        vibrateHorizontally()
        layer.borderColor = ColorPalette.errorPulse.cgColor
        layer.borderWidth = 4

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.layer.borderWidth = 2
            self.layer.borderColor = ColorPalette.gridCellBorder.cgColor
        }
    }
}
