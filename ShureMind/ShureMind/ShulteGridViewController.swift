import UIKit

// Shulte Grid game view controller
class ShulteGridViewController: UIViewController {
    private var gridDimension: Int = 5
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
    private let difficultySelector = UISegmentedControl(items: ["5×5", "6×6", "7×7", "8×8", "9×9", "10×10"])
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
        difficultySelector.selectedSegmentTintColor = colors.accent2
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
        difficultySelector.translatesAutoresizingMaskIntoConstraints = false
        gridContainerView.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            timerLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            targetLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            targetLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            difficultySelector.topAnchor.constraint(equalTo: targetLabel.bottomAnchor, constant: 20),
            difficultySelector.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            difficultySelector.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            difficultySelector.heightAnchor.constraint(equalToConstant: 40),

            gridContainerView.topAnchor.constraint(equalTo: difficultySelector.bottomAnchor, constant: 30),
            gridContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gridContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            gridContainerView.heightAnchor.constraint(equalTo: gridContainerView.widthAnchor),

            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
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
        let buttonSize = (view.bounds.width * 0.9 - spacing * CGFloat(gridDimension + 1)) / CGFloat(gridDimension)

        // Generate shuffled numbers
        var numbers = Array(1...totalNumbers)
        numbers.shuffle()

        for row in 0..<gridDimension {
            for col in 0..<gridDimension {
                let button = UIButton()
                let number = numbers[row * gridDimension + col]
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
                    button.leadingAnchor.constraint(equalTo: gridContainerView.leadingAnchor, constant: spacing + CGFloat(col) * (buttonSize + spacing)),
                    button.topAnchor.constraint(equalTo: gridContainerView.topAnchor, constant: spacing + CGFloat(row) * (buttonSize + spacing))
                ])

                gridButtons.append(button)
            }
        }
    }

    @objc private func difficultyChanged() {
        gridDimension = difficultySelector.selectedSegmentIndex + 5
        totalNumbers = gridDimension * gridDimension
        generateGrid()
    }

    @objc private func startGame() {
        isGameActive = true
        currentTargetNumber = 1
        errorCount = 0
        startTime = Date()
        targetLabel.text = "Next: 1"
        startButton.isEnabled = false
        difficultySelector.isEnabled = false

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

        // 记录训练
        StreakTracker.shared.recordTrainingToday()

        // 更新成就
        AchievementSystem.shared.incrementAchievement(id: "first_game")
        AchievementSystem.shared.incrementAchievement(id: "ten_games")
        AchievementSystem.shared.incrementAchievement(id: "fifty_games")

        // 检查速度成就
        if gridDimension == 5 {
            if completionTime <= 20 {
                AchievementSystem.shared.updateAchievement(id: "speed_demon", value: 1)
            }
            if completionTime <= 15 {
                AchievementSystem.shared.updateAchievement(id: "speed_master", value: 1)
            }
            // 检查每日挑战
            DailyChallengeManager.shared.checkAndCompleteChallenge(type: .speedRun, value: completionTime)
        }

        // 检查大网格成就
        if gridDimension == 10 {
            AchievementSystem.shared.updateAchievement(id: "grid_master", value: 1)
        }
        if gridDimension == 9 {
            DailyChallengeManager.shared.checkAndCompleteChallenge(type: .largeGrid, value: 1)
        }

        // Save performance
        let metrics = CognitiveMetrics(gridDimension: gridDimension, completionDuration: completionTime, accuracyRate: 1.0)
        PerformanceArchive.shared.archiveCognitiveSession(metrics)

        // Check for best time
        let bestTime = PerformanceArchive.shared.fetchOptimalDuration(forDimension: gridDimension)
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
        difficultySelector.isEnabled = true
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
