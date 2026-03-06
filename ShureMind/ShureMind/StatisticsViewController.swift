import UIKit

// Statistics and performance history view controller
class StatisticsViewController: UIViewController {
    private let headerView = UIView()
    private let backButton = UIButton()
    private let titleLabel = UILabel()
    private let segmentControl = UISegmentedControl(items: ["Neural Grid", "Visual Sequence"])
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadStatistics()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyGradientBackground(colors: [ColorPalette.primaryDark, ColorPalette.primaryMid])
    }

    private func setupUI() {
        // Header view
        headerView.backgroundColor = .clear
        view.addSubview(headerView)

        // Back button
        backButton.setTitle("←", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .light)
        backButton.setTitleColor(ColorPalette.textPrimary, for: .normal)
        backButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        headerView.addSubview(backButton)

        // Title label
        titleLabel.text = "Performance Archive"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = ColorPalette.textPrimary
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)

        // Segment control
        segmentControl.selectedSegmentIndex = 0
        segmentControl.backgroundColor = ColorPalette.cardBackground
        segmentControl.selectedSegmentTintColor = ColorPalette.accentPurple
        segmentControl.setTitleTextAttributes([.foregroundColor: ColorPalette.textPrimary], for: .normal)
        segmentControl.setTitleTextAttributes([.foregroundColor: ColorPalette.textPrimary], for: .selected)
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        view.addSubview(segmentControl)

        // Scroll view
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)

        // Content stack view
        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.alignment = .fill
        scrollView.addSubview(contentStackView)

        setupConstraints()
    }

    private func setupConstraints() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            segmentControl.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            segmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            segmentControl.heightAnchor.constraint(equalToConstant: 40),

            scrollView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }

    private func loadStatistics() {
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if segmentControl.selectedSegmentIndex == 0 {
            loadCognitiveStatistics()
        } else {
            loadRecollectionStatistics()
        }
    }

    private func loadCognitiveStatistics() {
        let records = PerformanceArchive.shared.retrieveCognitiveHistory()

        if records.isEmpty {
            showEmptyState(message: "No training records yet.\nStart your first session!")
            return
        }

        // Group by grid dimension
        let groupedRecords = Dictionary(grouping: records) { $0.gridDimension }

        for dimension in (5...10).sorted(by: >) {
            guard let dimensionRecords = groupedRecords[dimension], !dimensionRecords.isEmpty else { continue }

            let bestTime = dimensionRecords.map { $0.completionDuration }.min() ?? 0
            let avgTime = dimensionRecords.map { $0.completionDuration }.reduce(0, +) / Double(dimensionRecords.count)
            let totalSessions = dimensionRecords.count

            let card = createStatCard(
                title: "\(dimension)×\(dimension) Grid",
                stats: [
                    ("Best Time", String(format: "%.2fs", bestTime)),
                    ("Average", String(format: "%.2fs", avgTime)),
                    ("Sessions", "\(totalSessions)")
                ]
            )
            contentStackView.addArrangedSubview(card)
        }
    }

    private func loadRecollectionStatistics() {
        let records = PerformanceArchive.shared.retrieveRecollectionHistory()

        if records.isEmpty {
            showEmptyState(message: "No training records yet.\nStart your first session!")
            return
        }

        // Group by image quantity
        let groupedRecords = Dictionary(grouping: records) { $0.imageQuantity }

        for quantity in (3...10).sorted(by: >) {
            guard let quantityRecords = groupedRecords[quantity], !quantityRecords.isEmpty else { continue }

            let successCount = quantityRecords.filter { $0.isSuccessful }.count
            let totalSessions = quantityRecords.count
            let successRate = Double(successCount) / Double(totalSessions) * 100
            let avgAttempts = quantityRecords.map { Double($0.attemptsUsed) }.reduce(0, +) / Double(totalSessions)

            let card = createStatCard(
                title: "\(quantity) Images",
                stats: [
                    ("Success Rate", String(format: "%.0f%%", successRate)),
                    ("Avg Attempts", String(format: "%.1f", avgAttempts)),
                    ("Sessions", "\(totalSessions)")
                ]
            )
            contentStackView.addArrangedSubview(card)
        }
    }

    private func createStatCard(title: String, stats: [(String, String)]) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = ColorPalette.cardBackground
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = ColorPalette.accentPurple.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 8
        cardView.layer.shadowOpacity = 0.3

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = ColorPalette.textPrimary
        cardView.addSubview(titleLabel)

        let statsStackView = UIStackView()
        statsStackView.axis = .horizontal
        statsStackView.distribution = .fillEqually
        statsStackView.spacing = 12
        cardView.addSubview(statsStackView)

        for (label, value) in stats {
            let statView = createStatItem(label: label, value: value)
            statsStackView.addArrangedSubview(statView)
        }

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        statsStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(equalToConstant: 120),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            statsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            statsStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            statsStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            statsStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])

        return cardView
    }

    private func createStatItem(label: String, value: String) -> UIView {
        let container = UIView()

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        valueLabel.textColor = ColorPalette.accentCyan
        valueLabel.textAlignment = .center
        container.addSubview(valueLabel)

        let labelLabel = UILabel()
        labelLabel.text = label
        labelLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        labelLabel.textColor = ColorPalette.textSecondary
        labelLabel.textAlignment = .center
        container.addSubview(labelLabel)

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        labelLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: container.topAnchor),
            valueLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            labelLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            labelLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            labelLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    private func showEmptyState(message: String) {
        let emptyLabel = UILabel()
        emptyLabel.text = message
        emptyLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        emptyLabel.textColor = ColorPalette.textSecondary
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        contentStackView.addArrangedSubview(emptyLabel)

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyLabel.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    @objc private func segmentChanged() {
        loadStatistics()
    }

    @objc private func dismissView() {
        dismiss(animated: true)
    }
}
