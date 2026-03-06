import UIKit

// Shulte Grid game view controller
class ShulteGridViewController: UIViewController {
    private var currentShape: GridShape = .diamond
    private var currentTargetNumber: Int = 1
    private var totalNumbers: Int = 25
    private var startTime: Date?
    private var isGameActive = false
    private var errorCount: Int = 0

    private let headerView = UIView()
    private let backButton = UIButton()
    private let timerLabel = UILabel()
    private let targetLabel = UILabel()
    private let gridContainerView = UIView()
    private let shapeSelector = UISegmentedControl(items: GridShape.allCases.map { $0.displayName })
    private let startButton = StylizedButton()

    private var gridButtons: [UIButton] = []
    private var timer: Timer?

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

        view.applyGradientBackground(colors: [colors.bgGradientTop, colors.bgGradientMid])
        timerLabel.textColor = colors.accent1
        shapeSelector.selectedSegmentTintColor = colors.accent2
    }

    private func setupUI() {
        // Header view
        headerView.backgroundColor = .clear
        view.addSubview(headerView)

        // Back button
        backButton.setTitle("←", for: .normal)
        backButton.titleLabel?.font = FontManager.displaySmall()
        backButton.setTitleColor(ColorPalette.textPrimary, for: .normal)
        backButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        headerView.addSubview(backButton)

        // Timer label
        timerLabel.text = "00:00.00"
        timerLabel.font = FontManager.monospacedMedium()
        timerLabel.textColor = ColorPalette.accentCyan
        timerLabel.textAlignment = .center
        headerView.addSubview(timerLabel)

        // Target number label
        targetLabel.text = "Next: 1"
        targetLabel.font = FontManager.headlineMedium()
        targetLabel.textColor = ColorPalette.textPrimary
        targetLabel.textAlignment = .center
        view.addSubview(targetLabel)

        // Shape selector
        shapeSelector.selectedSegmentIndex = 0
        shapeSelector.backgroundColor = ColorPalette.cardBackground
        shapeSelector.selectedSegmentTintColor = ColorPalette.accentPurple
        shapeSelector.setTitleTextAttributes([.foregroundColor: ColorPalette.textPrimary, .font: UIFont.systemFont(ofSize: 11)], for: .normal)
        shapeSelector.setTitleTextAttributes([.foregroundColor: ColorPalette.textPrimary, .font: UIFont.systemFont(ofSize: 11, weight: .medium)], for: .selected)
        shapeSelector.addTarget(self, action: #selector(shapeChanged), for: .valueChanged)
        view.addSubview(shapeSelector)

        // Grid container
        gridContainerView.backgroundColor = .clear
        view.addSubview(gridContainerView)

        // Start button
        startButton.buttonTitle = "Start Training"
        startButton.addTarget(self, action: #selector(startGame), for: .touchUpInside)
        view.addSubview(startButton)

        setupConstraints()
        generateGrid()
    }

    private func setupConstraints() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        targetLabel.translatesAutoresizingMaskIntoConstraints = false
        shapeSelector.translatesAutoresizingMaskIntoConstraints = false
        gridContainerView.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false

        // Grid width constraint (preferred)
        let gridWidthConstraint = gridContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9)
        gridWidthConstraint.priority = .defaultHigh

        // Grid height constraint (square aspect ratio, preferred)
        let gridHeightConstraint = gridContainerView.heightAnchor.constraint(equalTo: gridContainerView.widthAnchor)
        gridHeightConstraint.priority = .defaultHigh

        // Maximum height constraint to prevent overflow (required)
        let maxHeightConstraint = gridContainerView.bottomAnchor.constraint(lessThanOrEqualTo: startButton.topAnchor, constant: -20)
        maxHeightConstraint.priority = .required

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            timerLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            targetLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12),
            targetLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            shapeSelector.topAnchor.constraint(equalTo: targetLabel.bottomAnchor, constant: 12),
            shapeSelector.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shapeSelector.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            shapeSelector.heightAnchor.constraint(equalToConstant: 40),

            gridContainerView.topAnchor.constraint(equalTo: shapeSelector.bottomAnchor, constant: 20),
            gridContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gridWidthConstraint,
            gridHeightConstraint,
            maxHeightConstraint,

            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            startButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func generateGrid() {
        // Clear existing grid
        gridButtons.forEach { $0.removeFromSuperview() }
        gridButtons.removeAll()

        let spacing: CGFloat = 8
        let containerSize = CGSize(width: view.bounds.width * 0.9, height: view.bounds.height * 0.5)

        // Get positions for current shape
        let positions = currentShape.generatePositions(containerSize: containerSize, spacing: spacing)

        // Calculate button size based on shape
        let buttonSize: CGFloat = min(containerSize.width / 8, 50)

        // Generate shuffled numbers
        var numbers = Array(1...totalNumbers)
        numbers.shuffle()

        for (index, position) in positions.enumerated() {
            guard index < numbers.count else { break }

            let button = UIButton()
            let number = numbers[index]
            button.setTitle("\(number)", for: .normal)
            button.titleLabel?.font = FontManager.gridNumber(forCellSize: buttonSize)
            button.backgroundColor = ColorPalette.gridCellDefault
            button.setTitleColor(ColorPalette.textPrimary, for: .normal)
            button.layer.cornerRadius = 8
            button.tag = number
            button.addTarget(self, action: #selector(gridButtonTapped(_:)), for: .touchUpInside)
            button.isEnabled = false

            gridContainerView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: buttonSize),
                button.heightAnchor.constraint(equalToConstant: buttonSize),
                button.leadingAnchor.constraint(equalTo: gridContainerView.leadingAnchor, constant: position.x - buttonSize / 2),
                button.topAnchor.constraint(equalTo: gridContainerView.topAnchor, constant: position.y - buttonSize / 2)
            ])

            gridButtons.append(button)
        }
    }

    @objc private func shapeChanged() {
        currentShape = GridShape.allCases[shapeSelector.selectedSegmentIndex]
        totalNumbers = currentShape.cellCount
        generateGrid()
    }

    @objc private func startGame() {
        isGameActive = true
        currentTargetNumber = 1
        errorCount = 0
        startTime = Date()
        targetLabel.text = "Next: 1"
        startButton.isEnabled = false
        shapeSelector.isEnabled = false

        gridButtons.forEach { button in
            button.isEnabled = true
            button.backgroundColor = ColorPalette.gridCellDefault
        }

        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }

        HapticFeedbackEngine.shared.triggerSuccess()
    }

    @objc private func gridButtonTapped(_ sender: UIButton) {
        let tappedNumber = sender.tag

        if tappedNumber == currentTargetNumber {
            // Correct tap
            sender.backgroundColor = ColorPalette.successGlow
            sender.pulsateWithColor(ColorPalette.successGlow, duration: 0.2)
            HapticFeedbackEngine.shared.triggerSuccess()

            // Reset to original state after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                sender.backgroundColor = ColorPalette.gridCellDefault
                sender.transform = .identity
                sender.layer.removeAllAnimations()
                sender.layer.shadowOpacity = 0
                sender.alpha = 1.0
            }

            currentTargetNumber += 1
            targetLabel.text = "Next: \(currentTargetNumber)"

            if currentTargetNumber > totalNumbers {
                completeGame()
            }
        } else {
            // Wrong tap
            sender.backgroundColor = ColorPalette.errorPulse
            sender.vibrateHorizontally()
            HapticFeedbackEngine.shared.triggerError()
            errorCount += 1

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                sender.backgroundColor = ColorPalette.gridCellDefault
                sender.transform = .identity
                sender.layer.removeAllAnimations()
                sender.layer.shadowOpacity = 0
                sender.alpha = 1.0
            }
        }
    }

    private func updateTimer() {
        guard let startTime = startTime else { return }
        let elapsed = Date().timeIntervalSince(startTime)
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60
        let milliseconds = Int((elapsed.truncatingRemainder(dividingBy: 1)) * 100)
        timerLabel.text = String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }

    private func completeGame() {
        isGameActive = false
        timer?.invalidate()
        timer = nil

        guard let startTime = startTime else { return }
        let completionTime = Date().timeIntervalSince(startTime)

        // Record training session
        StreakTracker.shared.recordTrainingToday()

        // Update achievements
        AchievementSystem.shared.incrementAchievement(id: "first_game")
        AchievementSystem.shared.incrementAchievement(id: "ten_games")
        AchievementSystem.shared.incrementAchievement(id: "fifty_games")

        // Check speed achievements
        if totalNumbers == 25 {
            if completionTime <= 20 {
                AchievementSystem.shared.updateAchievement(id: "speed_demon", value: 1)
            }
            if completionTime <= 15 {
                AchievementSystem.shared.updateAchievement(id: "speed_master", value: 1)
            }
            // Check daily challenge
            DailyChallengeManager.shared.checkAndCompleteChallenge(type: .speedRun, value: completionTime)
        }

        // Check large grid achievements
        if totalNumbers >= 36 {
            AchievementSystem.shared.updateAchievement(id: "grid_master", value: 1)
            DailyChallengeManager.shared.checkAndCompleteChallenge(type: .largeGrid, value: 1)
        }

        // Save performance (using totalNumbers as dimension equivalent)
        let metrics = CognitiveMetrics(gridDimension: totalNumbers, completionDuration: completionTime, accuracyRate: 1.0)
        PerformanceArchive.shared.archiveCognitiveSession(metrics)

        // Check for best time
        let bestTime = PerformanceArchive.shared.fetchOptimalDuration(forDimension: totalNumbers)
        let isNewRecord = bestTime == nil || completionTime < bestTime!

        let message = isNewRecord ?
            "New Record!\nTime: \(String(format: "%.2f", completionTime))s" :
            "Complete!\nTime: \(String(format: "%.2f", completionTime))s\nBest: \(String(format: "%.2f", bestTime ?? 0))s"

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
        startButton.isEnabled = true
        shapeSelector.isEnabled = true
        currentTargetNumber = 1
        timerLabel.text = "00:00.00"
        targetLabel.text = "Next: 1"
        generateGrid()
    }

    @objc private func dismissView() {
        timer?.invalidate()
        dismiss(animated: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
