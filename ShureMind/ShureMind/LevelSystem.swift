import Foundation
import UIKit

// MARK: - Player Level Tier
enum PlayerTier: String, Codable {
    case novice = "Novice"           // Lv 1-10
    case apprentice = "Apprentice"   // Lv 11-25
    case expert = "Expert"           // Lv 26-50
    case master = "Master"           // Lv 51-75
    case grandmaster = "Grandmaster" // Lv 76-99
    case legend = "Legend"           // Lv 100+

    var color: UIColor {
        switch self {
        case .novice: return UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        case .apprentice: return UIColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1.0)
        case .expert: return UIColor(red: 0.0, green: 0.6, blue: 1.0, alpha: 1.0)
        case .master: return UIColor(red: 0.6, green: 0.2, blue: 1.0, alpha: 1.0)
        case .grandmaster: return UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
        case .legend: return UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        }
    }

    var icon: String {
        switch self {
        case .novice: return "🌱"
        case .apprentice: return "📚"
        case .expert: return "⚡"
        case .master: return "🏆"
        case .grandmaster: return "👑"
        case .legend: return "🌟"
        }
    }
}

// MARK: - Player Profile
struct PlayerProfile: Codable {
    var level: Int
    var experience: Int
    var coins: Int
    var gems: Int
    var stars: Int
    var totalGamesPlayed: Int
    var totalTrainingTime: TimeInterval
    var bestScores: [String: Double]  // Game mode -> best score

    var tier: PlayerTier {
        switch level {
        case 1...10: return .novice
        case 11...25: return .apprentice
        case 26...50: return .expert
        case 51...75: return .master
        case 76...99: return .grandmaster
        default: return .legend
        }
    }

    var experienceToNextLevel: Int {
        return LevelSystem.shared.experienceRequired(for: level + 1)
    }

    var currentLevelExperience: Int {
        return LevelSystem.shared.experienceRequired(for: level)
    }

    var progressToNextLevel: Double {
        let currentLevelExp = currentLevelExperience
        let nextLevelExp = experienceToNextLevel
        let expInCurrentLevel = experience - currentLevelExp
        let expNeededForLevel = nextLevelExp - currentLevelExp
        return Double(expInCurrentLevel) / Double(expNeededForLevel)
    }
}

// MARK: - Level System Manager
class LevelSystem {
    static let shared = LevelSystem()
    private let userDefaults = UserDefaults.standard
    private let profileKey = "playerProfile"

    private init() {
        initializeProfile()
    }

    // MARK: - Profile Management

    private func initializeProfile() {
        if userDefaults.data(forKey: profileKey) == nil {
            let newProfile = PlayerProfile(
                level: 1,
                experience: 0,
                coins: 100,
                gems: 10,
                stars: 0,
                totalGamesPlayed: 0,
                totalTrainingTime: 0,
                bestScores: [:]
            )
            saveProfile(newProfile)
        }
    }

    func getProfile() -> PlayerProfile {
        guard let data = userDefaults.data(forKey: profileKey),
              let profile = try? JSONDecoder().decode(PlayerProfile.self, from: data) else {
            return PlayerProfile(
                level: 1,
                experience: 0,
                coins: 100,
                gems: 10,
                stars: 0,
                totalGamesPlayed: 0,
                totalTrainingTime: 0,
                bestScores: [:]
            )
        }
        return profile
    }

    private func saveProfile(_ profile: PlayerProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            userDefaults.set(data, forKey: profileKey)
            NotificationCenter.default.post(name: NSNotification.Name("ProfileUpdated"), object: profile)
        }
    }

    // MARK: - Experience System

    /// Calculate experience required for a specific level
    func experienceRequired(for level: Int) -> Int {
        if level <= 1 { return 0 }
        // Formula: 100 * level^1.5
        return Int(100.0 * pow(Double(level), 1.5))
    }

    /// Add experience and handle level ups
    func addExperience(_ amount: Int) {
        var profile = getProfile()
        profile.experience += amount

        // Check for level up
        var levelsGained = 0
        while profile.experience >= experienceRequired(for: profile.level + 1) {
            profile.level += 1
            levelsGained += 1
        }

        saveProfile(profile)

        // Notify level up
        if levelsGained > 0 {
            NotificationCenter.default.post(
                name: NSNotification.Name("PlayerLevelUp"),
                object: ["level": profile.level, "levelsGained": levelsGained]
            )

            // Award level up rewards
            awardLevelUpRewards(level: profile.level)
        }
    }

    // MARK: - Currency Management

    func addCoins(_ amount: Int) {
        var profile = getProfile()
        profile.coins += amount
        saveProfile(profile)
    }

    func spendCoins(_ amount: Int) -> Bool {
        var profile = getProfile()
        guard profile.coins >= amount else { return false }
        profile.coins -= amount
        saveProfile(profile)
        return true
    }

    func addGems(_ amount: Int) {
        var profile = getProfile()
        profile.gems += amount
        saveProfile(profile)
    }

    func spendGems(_ amount: Int) -> Bool {
        var profile = getProfile()
        guard profile.gems >= amount else { return false }
        profile.gems -= amount
        saveProfile(profile)
        return true
    }

    func addStars(_ amount: Int) {
        var profile = getProfile()
        profile.stars += amount
        saveProfile(profile)
    }

    func spendStars(_ amount: Int) -> Bool {
        var profile = getProfile()
        guard profile.stars >= amount else { return false }
        profile.stars -= amount
        saveProfile(profile)
        return true
    }

    // MARK: - Game Statistics

    func recordGamePlayed(mode: String, score: Double, duration: TimeInterval) {
        var profile = getProfile()
        profile.totalGamesPlayed += 1
        profile.totalTrainingTime += duration

        // Update best score if better
        if let currentBest = profile.bestScores[mode] {
            if score > currentBest {
                profile.bestScores[mode] = score
            }
        } else {
            profile.bestScores[mode] = score
        }

        saveProfile(profile)
    }

    // MARK: - Rewards

    private func awardLevelUpRewards(level: Int) {
        var coinsReward = 50 * level
        var gemsReward = 0

        // Special rewards at milestone levels
        switch level {
        case 5:
            gemsReward = 5
        case 10:
            gemsReward = 10
            coinsReward = 1000
        case 25:
            gemsReward = 25
            coinsReward = 2500
        case 50:
            gemsReward = 50
            coinsReward = 5000
        case 75:
            gemsReward = 75
            coinsReward = 10000
        case 100:
            gemsReward = 100
            coinsReward = 20000
        default:
            if level % 10 == 0 {
                gemsReward = level / 10
            }
        }

        addCoins(coinsReward)
        if gemsReward > 0 {
            addGems(gemsReward)
        }

        // Notify rewards
        NotificationCenter.default.post(
            name: NSNotification.Name("LevelUpRewards"),
            object: ["coins": coinsReward, "gems": gemsReward, "level": level]
        )
    }

    // MARK: - Experience Calculation

    /// Calculate experience reward based on performance
    func calculateExperienceReward(
        baseExp: Int,
        performanceMultiplier: Double = 1.0,
        perfectBonus: Bool = false,
        speedBonus: Bool = false
    ) -> Int {
        var totalExp = Double(baseExp) * performanceMultiplier

        if perfectBonus {
            totalExp *= 1.5
        }

        if speedBonus {
            totalExp *= 1.2
        }

        return Int(totalExp)
    }
}

// MARK: - Level Up Dialog
class LevelUpDialog: UIView {
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let levelLabel = UILabel()
    private let tierLabel = UILabel()
    private let rewardsLabel = UILabel()
    private let continueButton = StylizedButton()
    private let particleLayer = CAEmitterLayer()

    init(level: Int, tier: PlayerTier, coins: Int, gems: Int) {
        super.init(frame: .zero)
        setupUI(level: level, tier: tier, coins: coins, gems: gems)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(level: Int, tier: PlayerTier, coins: Int, gems: Int) {
        backgroundColor = UIColor.black.withAlphaComponent(0.8)

        // Container
        containerView.backgroundColor = ColorPalette.cardGlass
        containerView.layer.cornerRadius = 24
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = tier.color.cgColor
        addSubview(containerView)

        // Title
        titleLabel.text = "🎉 Level Up!"
        titleLabel.font = FontManager.displayMedium()
        titleLabel.textColor = ColorPalette.textPrimary
        titleLabel.textAlignment = .center
        containerView.addSubview(titleLabel)

        // Level
        levelLabel.text = "Level \(level)"
        levelLabel.font = FontManager.displayLarge()
        levelLabel.textColor = tier.color
        levelLabel.textAlignment = .center
        containerView.addSubview(levelLabel)

        // Tier
        tierLabel.text = "\(tier.icon) \(tier.rawValue)"
        tierLabel.font = FontManager.headlineLarge()
        tierLabel.textColor = tier.color
        tierLabel.textAlignment = .center
        containerView.addSubview(tierLabel)

        // Rewards
        var rewardsText = "Rewards:\n"
        rewardsText += "🪙 \(coins) Coins"
        if gems > 0 {
            rewardsText += "\n💎 \(gems) Gems"
        }
        rewardsLabel.text = rewardsText
        rewardsLabel.font = FontManager.bodyLarge()
        rewardsLabel.textColor = ColorPalette.textSecondary
        rewardsLabel.textAlignment = .center
        rewardsLabel.numberOfLines = 0
        containerView.addSubview(rewardsLabel)

        // Continue button
        continueButton.buttonTitle = "Continue"
        continueButton.buttonStyle = .success
        continueButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        containerView.addSubview(continueButton)

        setupConstraints()
        addParticleEffect(color: tier.color)
    }

    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        tierLabel.translatesAutoresizingMaskIntoConstraints = false
        rewardsLabel.translatesAutoresizingMaskIntoConstraints = false
        continueButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 320),
            containerView.heightAnchor.constraint(equalToConstant: 400),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            levelLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            levelLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            tierLabel.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 10),
            tierLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            rewardsLabel.topAnchor.constraint(equalTo: tierLabel.bottomAnchor, constant: 40),
            rewardsLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            rewardsLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8),

            continueButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -30),
            continueButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            continueButton.widthAnchor.constraint(equalToConstant: 200),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func addParticleEffect(color: UIColor) {
        particleLayer.emitterPosition = CGPoint(x: bounds.midX, y: bounds.midY)
        particleLayer.emitterShape = .circle
        particleLayer.emitterSize = CGSize(width: 300, height: 300)
        particleLayer.renderMode = .additive

        let cell = CAEmitterCell()
        cell.birthRate = 10
        cell.lifetime = 3.0
        cell.velocity = 100
        cell.velocityRange = 50
        cell.emissionRange = .pi * 2
        cell.scale = 0.1
        cell.scaleRange = 0.05
        cell.alphaSpeed = -0.3
        cell.color = color.cgColor
        cell.contents = createStarImage().cgImage

        particleLayer.emitterCells = [cell]
        layer.insertSublayer(particleLayer, at: 0)
    }

    private func createStarImage() -> UIImage {
        let size = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.white.cgColor)

        // Draw star
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 10, y: 0))
        path.addLine(to: CGPoint(x: 12, y: 8))
        path.addLine(to: CGPoint(x: 20, y: 8))
        path.addLine(to: CGPoint(x: 14, y: 13))
        path.addLine(to: CGPoint(x: 16, y: 20))
        path.addLine(to: CGPoint(x: 10, y: 15))
        path.addLine(to: CGPoint(x: 4, y: 20))
        path.addLine(to: CGPoint(x: 6, y: 13))
        path.addLine(to: CGPoint(x: 0, y: 8))
        path.addLine(to: CGPoint(x: 8, y: 8))
        path.close()
        path.fill()

        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    func show(in view: UIView) {
        frame = view.bounds
        view.addSubview(self)

        alpha = 0
        containerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
            self.alpha = 1
            self.containerView.transform = .identity
        }

        HapticFeedbackEngine.shared.triggerSuccess()
    }

    @objc private func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
            self.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.removeFromSuperview()
        }
    }
}
