import UIKit

// Picture Memory game view controller
class PictureMemoryViewController: UIViewController {
    private var imageQuantity: Int = 3
    private var sequenceToMemorize: [Int] = []
    private var selectedSequence: [Int] = []
    private var remainingAttempts: Int = 3
    private var isMemorizationPhase: Bool = false

    private let headerView = UIView()
    private let backButton = UIButton()
    private let attemptsLabel = UILabel()
    private let instructionLabel = UILabel()
    private let difficultyContainerView = UIView()
    private var difficultyButtons: [UIButton] = []
    private let startButton = StylizedButton()
    private let memorizationContainerView = UIView()
    private let selectionContainerView = UIView()
    private let selectedDisplayView = UIView()
    private let countdownLabel = UILabel()

    private var memorizationImageViews: [UIImageView] = []
    private var selectionButtons: [UIButton] = []
    private var selectedDisplayImageViews: [UIImageView] = []
    private var countdownTimer: Timer?
    private var countdownValue: Int = 10

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
        attemptsLabel.textColor = colors.accent1
        countdownLabel.textColor = colors.accent1
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

        // Attempts label
        attemptsLabel.text = "Attempt count: 3"
        attemptsLabel.font = FontManager.headlineSmall()
        attemptsLabel.textColor = ColorPalette.accentCyan
        attemptsLabel.textAlignment = .center
        headerView.addSubview(attemptsLabel)

        // Instruction label
        instructionLabel.text = "Choose Difficult"
        instructionLabel.font = FontManager.bodyLarge()
        instructionLabel.textColor = ColorPalette.textPrimary
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 2
        view.addSubview(instructionLabel)

        // Difficulty container
        difficultyContainerView.backgroundColor = .clear
        view.addSubview(difficultyContainerView)

        // Create difficulty buttons (2 rows x 4 columns)
        let difficulties = [3, 4, 5, 6, 7, 8, 9, 10]
        for (index, difficulty) in difficulties.enumerated() {
            let button = UIButton()
            button.setTitle("\(difficulty)", for: .normal)
            button.titleLabel?.font = FontManager.headlineLarge()
            button.setTitleColor(ColorPalette.textSecondary, for: .normal)
            button.backgroundColor = ColorPalette.cardBackground
            button.layer.cornerRadius = 16
            button.layer.borderWidth = 2
            button.layer.borderColor = ColorPalette.gridCellDefault.cgColor
            button.tag = difficulty
            button.addTarget(self, action: #selector(difficultyButtonTapped(_:)), for: .touchUpInside)

            difficultyContainerView.addSubview(button)
            difficultyButtons.append(button)
        }

        // Select default difficulty (3)
        if let firstButton = difficultyButtons.first {
            selectDifficultyButton(firstButton)
        }

        // Memorization container
        memorizationContainerView.backgroundColor = .clear
        memorizationContainerView.isHidden = true
        view.addSubview(memorizationContainerView)

        // Countdown label
        countdownLabel.font = FontManager.monospacedLarge()
        countdownLabel.textColor = ColorPalette.accentCyan
        countdownLabel.textAlignment = .center
        countdownLabel.isHidden = true
        memorizationContainerView.addSubview(countdownLabel)

        // Selected display view
        selectedDisplayView.backgroundColor = .clear
        selectedDisplayView.isHidden = true
        view.addSubview(selectedDisplayView)

        // Selection container
        selectionContainerView.backgroundColor = .clear
        selectionContainerView.isHidden = true
        view.addSubview(selectionContainerView)

        // Start button
        startButton.buttonTitle = "Start Training"
        startButton.addTarget(self, action: #selector(startGame), for: .touchUpInside)
        view.addSubview(startButton)

        setupConstraints()
    }

    private func setupConstraints() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        attemptsLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        difficultyContainerView.translatesAutoresizingMaskIntoConstraints = false
        memorizationContainerView.translatesAutoresizingMaskIntoConstraints = false
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        selectedDisplayView.translatesAutoresizingMaskIntoConstraints = false
        selectionContainerView.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            attemptsLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            attemptsLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            instructionLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 40),
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),

            difficultyContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            difficultyContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            difficultyContainerView.widthAnchor.constraint(equalToConstant: 340),
            difficultyContainerView.heightAnchor.constraint(equalToConstant: 180),

            memorizationContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            memorizationContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            memorizationContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            memorizationContainerView.heightAnchor.constraint(equalToConstant: 320),

            countdownLabel.centerXAnchor.constraint(equalTo: memorizationContainerView.centerXAnchor),
            countdownLabel.bottomAnchor.constraint(equalTo: memorizationContainerView.bottomAnchor, constant: -20),

            selectedDisplayView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 100),
            selectedDisplayView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectedDisplayView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            selectedDisplayView.heightAnchor.constraint(equalToConstant: 90),

            selectionContainerView.topAnchor.constraint(equalTo: selectedDisplayView.bottomAnchor, constant: 60),
            selectionContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectionContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            selectionContainerView.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -20),

            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            startButton.heightAnchor.constraint(equalToConstant: 56)
        ])

        // Layout difficulty buttons in 2x4 grid
        let buttonSize: CGFloat = 75
        let spacing: CGFloat = 15

        for (index, button) in difficultyButtons.enumerated() {
            button.translatesAutoresizingMaskIntoConstraints = false
            let row = index / 4
            let col = index % 4

            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: buttonSize),
                button.heightAnchor.constraint(equalToConstant: buttonSize),
                button.leadingAnchor.constraint(equalTo: difficultyContainerView.leadingAnchor, constant: CGFloat(col) * (buttonSize + spacing)),
                button.topAnchor.constraint(equalTo: difficultyContainerView.topAnchor, constant: CGFloat(row) * (buttonSize + spacing))
            ])
        }
    }

    @objc private func difficultyButtonTapped(_ sender: UIButton) {
        selectDifficultyButton(sender)
        imageQuantity = sender.tag
        HapticFeedbackEngine.shared.triggerSelection()
    }

    private func selectDifficultyButton(_ button: UIButton) {
        // Deselect all buttons
        difficultyButtons.forEach { btn in
            btn.backgroundColor = ColorPalette.cardBackground
            btn.layer.borderColor = ColorPalette.gridCellDefault.cgColor
            btn.setTitleColor(ColorPalette.textSecondary, for: .normal)
            btn.transform = .identity
        }

        // Select the tapped button
        button.backgroundColor = ColorPalette.accentPurple.withAlphaComponent(0.3)
        button.layer.borderColor = ColorPalette.accentPurple.cgColor
        button.setTitleColor(ColorPalette.accentPurple, for: .normal)
        UIView.animate(withDuration: 0.2) {
            button.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }
    }

    @objc private func startGame() {
        remainingAttempts = 3
        selectedSequence.removeAll()
        attemptsLabel.text = "Attempts: 3"
        instructionLabel.text = "Memorize the picture order"

        // Generate random sequence
        sequenceToMemorize = Array(1...imageQuantity).shuffled()

        // Hide setup UI
        difficultyContainerView.isHidden = true
        startButton.isHidden = true

        // Show memorization phase
        showMemorizationPhase()
    }

    private func showMemorizationPhase() {
        isMemorizationPhase = true
        memorizationContainerView.isHidden = false
        countdownLabel.isHidden = false

        // Clear previous views
        memorizationImageViews.forEach { $0.removeFromSuperview() }
        memorizationImageViews.removeAll()

        // Calculate layout
        let spacing: CGFloat = 10

        // Determine grid layout: 1 row for <=5 images, 2 rows for >5 images
        let columns: Int
        let rows: Int
        if imageQuantity <= 5 {
            columns = imageQuantity
            rows = 1
        } else {
            rows = 2
            columns = (imageQuantity + 1) / 2  // Distribute evenly across 2 rows
        }

        // Calculate available space
        let containerWidth = view.bounds.width * 0.9
        let containerHeight: CGFloat = 280

        // Calculate image size to fit the container
        let availableWidth = containerWidth - CGFloat(columns - 1) * spacing
        let availableHeight = containerHeight - CGFloat(rows - 1) * spacing

        let imageSizeByWidth = availableWidth / CGFloat(columns)
        let imageSizeByHeight = availableHeight / CGFloat(rows)
        let imageSize = min(imageSizeByWidth, imageSizeByHeight, 120)

        // Calculate grid position (centered)
        let totalGridWidth = CGFloat(columns) * imageSize + CGFloat(columns - 1) * spacing
        let totalGridHeight = CGFloat(rows) * imageSize + CGFloat(rows - 1) * spacing
        let startX = (containerWidth - totalGridWidth) / 2
        let startY = (containerHeight - totalGridHeight) / 2

        // Display images in sequence
        for (index, imageNumber) in sequenceToMemorize.enumerated() {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "memory-\(imageNumber)")
            imageView.contentMode = .scaleAspectFit
            imageView.layer.cornerRadius = 12
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 3
            imageView.layer.borderColor = ColorPalette.accentCyan.cgColor

            let row = index / columns
            let col = index % columns
            let xOffset = startX + CGFloat(col) * (imageSize + spacing)
            let yOffset = startY + CGFloat(row) * (imageSize + spacing)

            memorizationContainerView.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: imageSize),
                imageView.heightAnchor.constraint(equalToConstant: imageSize),
                imageView.leadingAnchor.constraint(equalTo: memorizationContainerView.leadingAnchor, constant: xOffset),
                imageView.topAnchor.constraint(equalTo: memorizationContainerView.topAnchor, constant: yOffset)
            ])

            imageView.alpha = 0
            imageView.fadeInWithScale(duration: 0.4)

            memorizationImageViews.append(imageView)
        }

        // Start countdown
        countdownValue = 10
        countdownLabel.text = "\(countdownValue)"
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateCountdown()
        }

        HapticFeedbackEngine.shared.triggerSuccess()
    }

    private func updateCountdown() {
        countdownValue -= 1
        countdownLabel.text = "\(countdownValue)"

        if countdownValue <= 0 {
            countdownTimer?.invalidate()
            countdownTimer = nil
            startSelectionPhase()
        } else if countdownValue <= 3 {
            countdownLabel.textColor = ColorPalette.errorPulse
            HapticFeedbackEngine.shared.triggerImpact(intensity: .light)
        }
    }

    private func startSelectionPhase() {
        isMemorizationPhase = false
        memorizationContainerView.isHidden = true
        selectedDisplayView.isHidden = false
        selectionContainerView.isHidden = false
        instructionLabel.text = "Select pictures in order"

        setupSelectionButtons()
        HapticFeedbackEngine.shared.triggerSuccess()
    }

    private func setupSelectionButtons() {
        // Clear previous buttons
        selectionButtons.forEach { $0.removeFromSuperview() }
        selectionButtons.removeAll()

        // Create 10 selection buttons
        let spacing: CGFloat = 12
        let columns = 5
        let rows = 2
        let buttonSize: CGFloat = (view.bounds.width * 0.9 - spacing * CGFloat(columns + 1)) / CGFloat(columns)

        for imageNumber in 1...10 {
            let button = UIButton()
            button.setImage(UIImage(named: "memory-\(imageNumber)"), for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.layer.cornerRadius = 12
            button.layer.masksToBounds = true
            button.layer.borderWidth = 2
            button.layer.borderColor = ColorPalette.gridCellDefault.cgColor
            button.backgroundColor = ColorPalette.cardBackground
            button.tag = imageNumber
            button.addTarget(self, action: #selector(imageSelected(_:)), for: .touchUpInside)

            let index = imageNumber - 1
            let row = index / columns
            let col = index % columns
            let xOffset = spacing + CGFloat(col) * (buttonSize + spacing)
            let yOffset = spacing + CGFloat(row) * (buttonSize + spacing)

            selectionContainerView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: buttonSize),
                button.heightAnchor.constraint(equalToConstant: buttonSize),
                button.leadingAnchor.constraint(equalTo: selectionContainerView.leadingAnchor, constant: xOffset),
                button.topAnchor.constraint(equalTo: selectionContainerView.topAnchor, constant: yOffset)
            ])

            selectionButtons.append(button)
        }
    }

    @objc private func imageSelected(_ sender: UIButton) {
        let selectedImageNumber = sender.tag

        // Add to selected sequence
        selectedSequence.append(selectedImageNumber)
        sender.isEnabled = false
        sender.alpha = 0.5

        // Display selected image
        updateSelectedDisplay()

        // Check if sequence is complete
        if selectedSequence.count == imageQuantity {
            checkSequence()
        }

        HapticFeedbackEngine.shared.triggerSelection()
    }

    private func updateSelectedDisplay() {
        // Clear previous display
        selectedDisplayImageViews.forEach { $0.removeFromSuperview() }
        selectedDisplayImageViews.removeAll()

        let spacing: CGFloat = 8
        let imageSize: CGFloat = 70

        // Use 2 rows if more than 5 images
        let columns: Int
        let rows: Int
        if selectedSequence.count <= 5 {
            columns = selectedSequence.count
            rows = 1
        } else {
            rows = 2
            columns = (selectedSequence.count + 1) / 2
        }

        let totalWidth = CGFloat(columns) * imageSize + CGFloat(columns - 1) * spacing
        let totalHeight = CGFloat(rows) * imageSize + CGFloat(rows - 1) * spacing
        let startX = (view.bounds.width * 0.9 - totalWidth) / 2
        let startY = (90 - totalHeight) / 2

        for (index, imageNumber) in selectedSequence.enumerated() {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "memory-\(imageNumber)")
            imageView.contentMode = .scaleAspectFit
            imageView.layer.cornerRadius = 8
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 2
            imageView.layer.borderColor = ColorPalette.accentPurple.cgColor

            let row = index / columns
            let col = index % columns
            let xOffset = startX + CGFloat(col) * (imageSize + spacing)
            let yOffset = startY + CGFloat(row) * (imageSize + spacing)

            selectedDisplayView.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: imageSize),
                imageView.heightAnchor.constraint(equalToConstant: imageSize),
                imageView.leadingAnchor.constraint(equalTo: selectedDisplayView.leadingAnchor, constant: xOffset),
                imageView.topAnchor.constraint(equalTo: selectedDisplayView.topAnchor, constant: yOffset)
            ])

            imageView.fadeInWithScale(duration: 0.3)
            selectedDisplayImageViews.append(imageView)
        }
    }

    private func checkSequence() {
        if selectedSequence == sequenceToMemorize {
            // Success
            gameCompleted(success: true)
        } else {
            // Failed attempt
            remainingAttempts -= 1
            attemptsLabel.text = "Attempts: \(remainingAttempts)"

            if remainingAttempts > 0 {
                showFailureAndRetry()
            } else {
                gameCompleted(success: false)
            }
        }
    }

    private func showFailureAndRetry() {
        HapticFeedbackEngine.shared.triggerError()

        let dialog = CustomDialogView(title: "Wrong Order", message: "Try again! \(remainingAttempts) attempts left", buttons: [
            (title: "Retry", action: { [weak self] in
                self?.retrySelection()
            })
        ])
        dialog.show(in: view)
    }

    private func retrySelection() {
        selectedSequence.removeAll()
        selectionButtons.forEach { button in
            button.isEnabled = true
            button.alpha = 1.0
        }
        updateSelectedDisplay()
    }

    private func gameCompleted(success: Bool) {
        // Record training
        StreakTracker.shared.recordTrainingToday()

        // Update achievements
        if success {
            AchievementSystem.shared.incrementAchievement(id: "first_game")
            AchievementSystem.shared.incrementAchievement(id: "ten_games")
            AchievementSystem.shared.incrementAchievement(id: "fifty_games")

            // Check perfect memory achievement
            if imageQuantity >= 10 && remainingAttempts == 3 {
                AchievementSystem.shared.updateAchievement(id: "perfect_memory", value: 1)
            }

            // Check daily challenge
            if imageQuantity >= 8 && remainingAttempts == 3 {
                DailyChallengeManager.shared.checkAndCompleteChallenge(type: .perfectAccuracy, value: Double(imageQuantity))
            }
        }

        // Save performance
        let metrics = RecollectionMetrics(imageQuantity: imageQuantity, attemptsUsed: 4 - remainingAttempts, isSuccessful: success)
        PerformanceArchive.shared.archiveRecollectionSession(metrics)

        let title = success ? "Perfect Memory!" : "Training Complete"
        let message = success ?
            "You correctly remembered all \(imageQuantity) pictures!" :
            "Keep practicing to improve your visual memory."

        let dialog = CustomDialogView(title: title, message: message, buttons: [
            (title: "Continue", action: { [weak self] in
                self?.resetGame()
            }),
            (title: "Exit", action: { [weak self] in
                self?.dismissView()
            })
        ])
        dialog.show(in: view)

        if success {
            HapticFeedbackEngine.shared.triggerSuccess()
        }
    }

    private func resetGame() {
        difficultyContainerView.isHidden = false
        startButton.isHidden = false
        memorizationContainerView.isHidden = true
        selectedDisplayView.isHidden = true
        selectionContainerView.isHidden = true
        instructionLabel.text = "Select difficulty and start"
        attemptsLabel.text = "Attempts: 3"
        countdownLabel.textColor = ColorPalette.accentCyan

        selectedSequence.removeAll()
        sequenceToMemorize.removeAll()
    }

    @objc private func dismissView() {
        countdownTimer?.invalidate()
        dismiss(animated: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
