import UIKit

// Enhanced custom dialog with game-style design
class CustomDialogView: UIView {
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let buttonStackView = UIStackView()
    private let iconView = UILabel()
    private let topAccentBar = UIView()

    var onDismiss: (() -> Void)?

    init(title: String, message: String, buttons: [(title: String, action: () -> Void)]) {
        super.init(frame: .zero)
        setupView(title: title, message: message, buttons: buttons)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(title: String, message: String, buttons: [(title: String, action: () -> Void)]) {
        backgroundColor = UIColor.black.withAlphaComponent(0.75)

        // Container with glass morphism
        containerView.backgroundColor = ColorPalette.panelDark
        containerView.layer.cornerRadius = 24
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = ColorPalette.cardGlassBorder.cgColor
        containerView.addNeonGlow(color: ColorPalette.neonPurple, radius: 30, opacity: 0.6)
        addSubview(containerView)

        // Top accent bar
        topAccentBar.layer.cornerRadius = 24
        topAccentBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            ColorPalette.neonCyan.cgColor,
            ColorPalette.neonPurple.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        topAccentBar.layer.insertSublayer(gradientLayer, at: 0)
        containerView.addSubview(topAccentBar)

        // Icon/emoji
        iconView.text = determineIcon(for: title)
        iconView.font = UIFont.systemFont(ofSize: 48)
        iconView.textAlignment = .center
        containerView.addSubview(iconView)

        // Title label with glow
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 26, weight: .black)
        titleLabel.textColor = ColorPalette.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.addNeonGlow(color: ColorPalette.neonCyan, radius: 10, opacity: 0.6)
        containerView.addSubview(titleLabel)

        // Message label
        messageLabel.text = message
        messageLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        messageLabel.textColor = ColorPalette.textSecondary
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        containerView.addSubview(messageLabel)

        // Button stack
        buttonStackView.axis = buttons.count > 2 ? .vertical : .horizontal
        buttonStackView.spacing = 12
        buttonStackView.distribution = .fillEqually
        containerView.addSubview(buttonStackView)

        for (index, buttonInfo) in buttons.enumerated() {
            let button = StylizedButton()
            button.buttonTitle = buttonInfo.title
            button.buttonStyle = index == 0 ? .primary : (index == 1 ? .secondary : .success)
            button.addAction(UIAction { [weak self] _ in
                buttonInfo.action()
                self?.dismiss()
            }, for: .touchUpInside)
            buttonStackView.addArrangedSubview(button)
        }

        setupConstraints()
    }

    private func determineIcon(for title: String) -> String {
        if title.contains("Complete") || title.contains("Perfect") {
            return "🎉"
        } else if title.contains("Record") {
            return "🏆"
        } else if title.contains("Incorrect") || title.contains("Failed") {
            return "⚠️"
        } else {
            return "✨"
        }
    }

    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        topAccentBar.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 340),

            topAccentBar.topAnchor.constraint(equalTo: containerView.topAnchor),
            topAccentBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            topAccentBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            topAccentBar.heightAnchor.constraint(equalToConstant: 6),

            iconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 28),
            iconView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),

            buttonStackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 28),
            buttonStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            buttonStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            buttonStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -28),
            buttonStackView.heightAnchor.constraint(equalToConstant: buttonStackView.axis == .vertical ? 120 : 56)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradientLayer = topAccentBar.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = topAccentBar.bounds
        }
    }

    func show(in view: UIView) {
        frame = view.bounds
        view.addSubview(self)

        // Initial state
        alpha = 0
        containerView.alpha = 0
        containerView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)

        // Animate background
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
        }

        // Animate container with bounce
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
            self.containerView.alpha = 1
            self.containerView.transform = .identity
        }

        // Animate icon
        iconView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        UIView.animate(withDuration: 0.6, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0) {
            self.iconView.transform = .identity
        }

        // Haptic feedback
        HapticFeedbackEngine.shared.triggerSuccess()
    }

    func dismiss() {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
            self.containerView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }) { _ in
            self.removeFromSuperview()
            self.onDismiss?()
        }
    }
}
