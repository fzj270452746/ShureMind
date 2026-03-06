import Foundation

// Achievement type
enum AchievementCategory: String, Codable {
    case beginner = "Beginner"
    case speed = "Speed"
    case accuracy = "Accuracy"
    case dedication = "Dedication"
    case master = "Master"
}

// Achievement model
struct Achievement: Codable {
    let id: String
    let category: AchievementCategory
    let title: String
    let description: String
    let icon: String
    let requiredValue: Int
    var currentValue: Int
    var isUnlocked: Bool
    let points: Int

    var progress: Double {
        return min(Double(currentValue) / Double(requiredValue), 1.0)
    }
}

// Achievement system manager
class AchievementSystem {
    static let shared = AchievementSystem()
    private let userDefaults = UserDefaults.standard
    private let achievementsKey = "achievements"

    private init() {
        initializeAchievements()
    }

    // Initialize achievements list
    private func initializeAchievements() {
        if userDefaults.data(forKey: achievementsKey) == nil {
            let achievements = createDefaultAchievements()
            saveAchievements(achievements)
        }
    }

    // Create default achievements
    private func createDefaultAchievements() -> [Achievement] {
        return [
            // Beginner achievements
            Achievement(
                id: "first_game",
                category: .beginner,
                title: "First Try",
                description: "Complete your first training",
                icon: "🎮",
                requiredValue: 1,
                currentValue: 0,
                isUnlocked: false,
                points: 10
            ),
            Achievement(
                id: "ten_games",
                category: .beginner,
                title: "Getting Started",
                description: "Complete 10 training sessions",
                icon: "📚",
                requiredValue: 10,
                currentValue: 0,
                isUnlocked: false,
                points: 25
            ),
            Achievement(
                id: "fifty_games",
                category: .beginner,
                title: "Dedicated Learner",
                description: "Complete 50 training sessions",
                icon: "🎓",
                requiredValue: 50,
                currentValue: 0,
                isUnlocked: false,
                points: 50
            ),

            // Speed achievements
            Achievement(
                id: "speed_demon",
                category: .speed,
                title: "Speed Demon",
                description: "Complete 5×5 grid in 20 seconds",
                icon: "⚡️",
                requiredValue: 1,
                currentValue: 0,
                isUnlocked: false,
                points: 75
            ),
            Achievement(
                id: "speed_master",
                category: .speed,
                title: "Speed Master",
                description: "Complete 5×5 grid in 15 seconds",
                icon: "🚀",
                requiredValue: 1,
                currentValue: 0,
                isUnlocked: false,
                points: 100
            ),

            // Accuracy achievements
            Achievement(
                id: "perfect_memory",
                category: .accuracy,
                title: "Perfect Memory",
                description: "Remember 10 pictures in one try",
                icon: "🎯",
                requiredValue: 1,
                currentValue: 0,
                isUnlocked: false,
                points: 100
            ),
            Achievement(
                id: "no_mistakes",
                category: .accuracy,
                title: "Flawless",
                description: "5 consecutive trainings without errors",
                icon: "💎",
                requiredValue: 5,
                currentValue: 0,
                isUnlocked: false,
                points: 150
            ),

            // Dedication achievements
            Achievement(
                id: "week_streak",
                category: .dedication,
                title: "Week Warrior",
                description: "Train for 7 consecutive days",
                icon: "🔥",
                requiredValue: 7,
                currentValue: 0,
                isUnlocked: false,
                points: 100
            ),
            Achievement(
                id: "month_streak",
                category: .dedication,
                title: "Monthly Master",
                description: "Train for 30 consecutive days",
                icon: "🏆",
                requiredValue: 30,
                currentValue: 0,
                isUnlocked: false,
                points: 500
            ),

            // Master achievements
            Achievement(
                id: "grid_master",
                category: .master,
                title: "Grid Master",
                description: "Complete 10×10 grid",
                icon: "👑",
                requiredValue: 1,
                currentValue: 0,
                isUnlocked: false,
                points: 200
            ),
            Achievement(
                id: "ultimate_champion",
                category: .master,
                title: "Ultimate Champion",
                description: "Unlock all other achievements",
                icon: "🌟",
                requiredValue: 1,
                currentValue: 0,
                isUnlocked: false,
                points: 1000
            )
        ]
    }

    // Get all achievements
    func getAllAchievements() -> [Achievement] {
        guard let data = userDefaults.data(forKey: achievementsKey),
              let achievements = try? JSONDecoder().decode([Achievement].self, from: data) else {
            return createDefaultAchievements()
        }
        return achievements
    }

    // Save achievements
    private func saveAchievements(_ achievements: [Achievement]) {
        if let data = try? JSONEncoder().encode(achievements) {
            userDefaults.set(data, forKey: achievementsKey)
        }
    }

    // Update achievement progress
    func updateAchievement(id: String, value: Int) {
        var achievements = getAllAchievements()

        if let index = achievements.firstIndex(where: { $0.id == id }) {
            achievements[index].currentValue = value

            if !achievements[index].isUnlocked && value >= achievements[index].requiredValue {
                achievements[index].isUnlocked = true

                // 发送解锁通知
                NotificationCenter.default.post(
                    name: NSNotification.Name("AchievementUnlocked"),
                    object: achievements[index]
                )

                // Add points
                DailyChallengeManager.shared.getTotalPoints()
            }

            saveAchievements(achievements)
            checkUltimateChampion()
        }
    }

    // Increment achievement progress
    func incrementAchievement(id: String, by amount: Int = 1) {
        var achievements = getAllAchievements()

        if let index = achievements.firstIndex(where: { $0.id == id }) {
            achievements[index].currentValue += amount

            if !achievements[index].isUnlocked && achievements[index].currentValue >= achievements[index].requiredValue {
                achievements[index].isUnlocked = true

                // 发送解锁通知
                NotificationCenter.default.post(
                    name: NSNotification.Name("AchievementUnlocked"),
                    object: achievements[index]
                )
            }

            saveAchievements(achievements)
            checkUltimateChampion()
        }
    }

    // Check if ultimate champion is unlocked
    private func checkUltimateChampion() {
        let achievements = getAllAchievements()
        let otherAchievements = achievements.filter { $0.id != "ultimate_champion" }
        let allUnlocked = otherAchievements.allSatisfy { $0.isUnlocked }

        if allUnlocked {
            updateAchievement(id: "ultimate_champion", value: 1)
        }
    }

    // Get unlocked achievement count
    func getUnlockedCount() -> Int {
        return getAllAchievements().filter { $0.isUnlocked }.count
    }

    // Get total achievement count
    func getTotalCount() -> Int {
        return getAllAchievements().count
    }

    // Get achievement completion rate
    func getCompletionRate() -> Double {
        let total = getTotalCount()
        guard total > 0 else { return 0 }
        return Double(getUnlockedCount()) / Double(total)
    }
}
