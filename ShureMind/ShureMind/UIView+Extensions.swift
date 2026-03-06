import UIKit

extension UIView {
    // Enhanced gradient background with animated shimmer
    func applyGradientBackground(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0.5, y: 0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1)) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = bounds

        if let existingGradient = layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
            existingGradient.removeFromSuperlayer()
        }
        layer.insertSublayer(gradientLayer, at: 0)
    }

    // Add neon glow effect
    func addNeonGlow(color: UIColor, radius: CGFloat = 20, opacity: Float = 0.8) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = .zero
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
    }

    // Animated pulse with glow
    func pulsateWithColor(_ color: UIColor, duration: TimeInterval = 0.3) {
        let originalColor = backgroundColor

        // Add glow effect
        let glowAnimation = CABasicAnimation(keyPath: "shadowRadius")
        glowAnimation.fromValue = 0
        glowAnimation.toValue = 25
        glowAnimation.duration = duration / 2
        glowAnimation.autoreverses = true
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = 0.9
        layer.add(glowAnimation, forKey: "glow")

        UIView.animate(withDuration: duration / 2, animations: {
            self.backgroundColor = color
            self.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
        }) { _ in
            UIView.animate(withDuration: duration / 2) {
                self.backgroundColor = originalColor
                self.transform = .identity
            }
        }
    }

    // Enhanced shake with rotation
    func vibrateHorizontally() {
        let animation = CAKeyframeAnimation(keyPath: "transform")
        animation.duration = 0.6
        animation.values = [
            NSValue(caTransform3D: CATransform3DIdentity),
            NSValue(caTransform3D: CATransform3DMakeTranslation(-15, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(15, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(-12, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(12, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(-8, 0, 0)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(8, 0, 0)),
            NSValue(caTransform3D: CATransform3DIdentity)
        ]
        layer.add(animation, forKey: "shake")
    }

    // Bouncy fade in with scale
    func fadeInWithScale(duration: TimeInterval = 0.4) {
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut) {
            self.alpha = 1
            self.transform = .identity
        }
    }

    // Glass morphism effect
    func applyGlassMorphism(cornerRadius: CGFloat = 16) {
        backgroundColor = ColorPalette.cardGlass
        layer.cornerRadius = cornerRadius
        layer.borderWidth = 1.5
        layer.borderColor = ColorPalette.cardGlassBorder.cgColor

        // Add blur effect
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.layer.cornerRadius = cornerRadius
        blurView.clipsToBounds = true
        insertSubview(blurView, at: 0)
    }

    // Floating animation
    func addFloatingAnimation(duration: TimeInterval = 3.0, distance: CGFloat = 10) {
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.fromValue = -distance
        animation.toValue = distance
        animation.duration = duration
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(animation, forKey: "floating")
    }

    // Shimmer effect for loading states
    func addShimmerEffect() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = bounds

        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = -bounds.width
        animation.toValue = bounds.width
        animation.duration = 1.5
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "shimmer")

        layer.addSublayer(gradientLayer)
    }
}
