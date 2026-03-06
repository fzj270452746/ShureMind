import UIKit

// Enhanced game-style button with multiple styles
class StylizedButton: UIButton {
    private let gradientLayer = CAGradientLayer()
    private let glowLayer = CALayer()
    private var particleEmitter: CAEmitterLayer?

    enum ButtonStyle {
        case primary
        case secondary
        case success
    }

    var buttonStyle: ButtonStyle = .primary {
        didSet {
            updateStyle()
        }
    }

    var buttonTitle: String = "" {
        didSet {
            setTitle(buttonTitle, for: .normal)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureAppearance()
    }

    private func configureAppearance() {
        // Gradient background
        layer.insertSublayer(gradientLayer, at: 0)

        // Styling
        titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        setTitleColor(ColorPalette.textPrimary, for: .normal)
        layer.cornerRadius = 16
        layer.masksToBounds = false

        // Enhanced shadow with glow
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.shadowRadius = 20
        layer.shadowOpacity = 0.7

        // Border glow
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor

        updateStyle()

        // Touch handlers
        addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        addTarget(self, action: #selector(buttonReleased), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    private func updateStyle() {
        let colors: [CGColor]
        let shadowColor: UIColor

        switch buttonStyle {
        case .primary:
            colors = [ColorPalette.btnPrimaryStart.cgColor, ColorPalette.btnPrimaryEnd.cgColor]
            shadowColor = ColorPalette.shadowCyan
        case .secondary:
            colors = [ColorPalette.btnSecondaryStart.cgColor, ColorPalette.btnSecondaryEnd.cgColor]
            shadowColor = ColorPalette.shadowPink
        case .success:
            colors = [ColorPalette.btnSuccessStart.cgColor, ColorPalette.btnSuccessEnd.cgColor]
            shadowColor = ColorPalette.neonGreen
        }

        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.shadowColor = shadowColor.cgColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius

        // Add animated border glow
        addPulsingBorderGlow()
    }

    private func addPulsingBorderGlow() {
        let animation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = UIColor.white.withAlphaComponent(0.1).cgColor
        animation.toValue = UIColor.white.withAlphaComponent(0.4).cgColor
        animation.duration = 1.5
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(animation, forKey: "borderGlow")
    }

    @objc private func buttonPressed() {
        HapticFeedbackEngine.shared.triggerImpact(intensity: .medium)

        // Scale down with bounce
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5) {
            self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }

        // Increase glow
        let glowAnimation = CABasicAnimation(keyPath: "shadowRadius")
        glowAnimation.fromValue = 20
        glowAnimation.toValue = 30
        glowAnimation.duration = 0.15
        layer.add(glowAnimation, forKey: "pressGlow")
    }

    @objc private func buttonReleased() {
        // Bounce back
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.8) {
            self.transform = .identity
        }

        // Reset glow
        let glowAnimation = CABasicAnimation(keyPath: "shadowRadius")
        glowAnimation.fromValue = 30
        glowAnimation.toValue = 20
        glowAnimation.duration = 0.3
        layer.add(glowAnimation, forKey: "releaseGlow")

        // Add particle burst effect
        addParticleBurst()
    }

    private func addParticleBurst() {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: bounds.midX, y: bounds.midY)
        emitter.emitterShape = .circle
        emitter.emitterSize = CGSize(width: 10, height: 10)
        emitter.renderMode = .additive

        let cell = CAEmitterCell()
        cell.birthRate = 30
        cell.lifetime = 0.5
        cell.velocity = 100
        cell.velocityRange = 50
        cell.emissionRange = .pi * 2
        cell.scale = 0.05
        cell.scaleRange = 0.02
        cell.alphaSpeed = -1.0

        switch buttonStyle {
        case .primary:
            cell.color = ColorPalette.neonCyan.cgColor
        case .secondary:
            cell.color = ColorPalette.neonPink.cgColor
        case .success:
            cell.color = ColorPalette.neonGreen.cgColor
        }

        cell.contents = createParticleImage().cgImage
        emitter.emitterCells = [cell]

        layer.addSublayer(emitter)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            emitter.removeFromSuperlayer()
        }
    }

    private func createParticleImage() -> UIImage {
        let size = CGSize(width: 10, height: 10)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
