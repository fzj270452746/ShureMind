import Foundation

// Daily challenge type
enum ChallengeType: String, Codable {
    case speedRun = "Speed Run"
    case perfectAccuracy = "Perfect Accuracy"
    case largeGrid = "Large Grid Master"
    case memoryMaster = "Memory Master"
    case streakBuilder = "Streak Builder"
}

// Daily challenge model
struct DailyChallenge: Codable {
    let id: String
    let type: ChallengeType
    let title: String
    let description: String
    let targetValue: Double
    let rewardPoints: Int
    let date: Date
    var isCompleted: Bool

    // Challenge icon
    var icon: String {
        switch type {
        case .speedRun: return "⚡️"
        case .perfectAccuracy: return "🎯"
        case .largeGrid: return "🔲"
        case .memoryMaster: return "🧠"
        case .streakBuilder: return "🔥"
        }
    }
}

// Daily challenge manager
class DailyChallengeManager {
    static let shared = DailyChallengeManager()
    private let userDefaults = UserDefaults.standard
    private let challengeKey = "dailyChallenges"
    private let lastGeneratedDateKey = "lastChallengeGeneratedDate"

    private init() {}

    // Get today's challenges
    func getTodayChallenges() -> [DailyChallenge] {
        let today = Calendar.current.startOfDay(for: Date())

        // Check if need to generate new challenges
        if let lastDate = userDefaults.object(forKey: lastGeneratedDateKey) as? Date {
            let lastDay = Calendar.current.startOfDay(for: lastDate)
            if lastDay < today {
                return generateNewChallenges()
            }
        } else {
            return generateNewChallenges()
        }

        // 加载已有挑战
        if let data = userDefaults.data(forKey: challengeKey),
           let challenges = try? JSONDecoder().decode([DailyChallenge].self, from: data) {
            return challenges
        }

        return generateNewChallenges()
    }

    // Generate new daily challenges
    private func generateNewChallenges() -> [DailyChallenge] {
        let today = Date()
        var challenges: [DailyChallenge] = []

        // Challenge 1: Speed challenge
        challenges.append(DailyChallenge(
            id: UUID().uuidString,
            type: .speedRun,
            title: "Lightning Speed",
            description: "Complete 5×5 Schulte Grid in 30 seconds",
            targetValue: 30.0,
            rewardPoints: 50,
            date: today,
            isCompleted: false
        ))

        // Challenge 2: Perfect accuracy
        challenges.append(DailyChallenge(
            id: UUID().uuidString,
            type: .perfectAccuracy,
            title: "Perfect Memory",
            description: "Correctly remember 8 picture sequences in one try",
            targetValue: 8.0,
            rewardPoints: 75,
            date: today,
            isCompleted: false
        ))

        // Challenge 3: Large grid challenge
        challenges.append(DailyChallenge(
            id: UUID().uuidString,
            type: .largeGrid,
            title: "Ultimate Challenge",
            description: "Complete one 9×9 Schulte Grid",
            targetValue: 1.0,
            rewardPoints: 100,
            date: today,
            isCompleted: false
        ))

        saveChallenges(challenges)
        userDefaults.set(today, forKey: lastGeneratedDateKey)

        return challenges
    }

    // Save challenges
    private func saveChallenges(_ challenges: [DailyChallenge]) {
        if let data = try? JSONEncoder().encode(challenges) {
            userDefaults.set(data, forKey: challengeKey)
        }
    }

    // Complete challenge
    func completeChallenge(withId id: String) {
        var challenges = getTodayChallenges()
        if let index = challenges.firstIndex(where: { $0.id == id }) {
            challenges[index].isCompleted = true
            saveChallenges(challenges)

            // Add reward points
            let points = challenges[index].rewardPoints
            addPoints(points)
        }
    }

    // Check and complete challenge
    func checkAndCompleteChallenge(type: ChallengeType, value: Double) {
        var challenges = getTodayChallenges()

        for (index, challenge) in challenges.enumerated() {
            if challenge.type == type && !challenge.isCompleted {
                let isCompleted: Bool

                switch type {
                case .speedRun:
                    isCompleted = value <= challenge.targetValue
                case .perfectAccuracy:
                    isCompleted = value >= challenge.targetValue
                case .largeGrid:
                    isCompleted = value >= challenge.targetValue
                case .memoryMaster:
                    isCompleted = value >= challenge.targetValue
                case .streakBuilder:
                    isCompleted = value >= challenge.targetValue
                }

                if isCompleted {
                    challenges[index].isCompleted = true
                    saveChallenges(challenges)
                    addPoints(challenge.rewardPoints)

                    // Send notification
                    NotificationCenter.default.post(
                        name: NSNotification.Name("ChallengeCompleted"),
                        object: challenge
                    )
                }
            }
        }
    }

    // Add points
    private func addPoints(_ points: Int) {
        let currentPoints = userDefaults.integer(forKey: "totalPoints")
        userDefaults.set(currentPoints + points, forKey: "totalPoints")
    }

    // Get total points
    func getTotalPoints() -> Int {
        return userDefaults.integer(forKey: "totalPoints")
    }

    // Get completion rate
    func getCompletionRate() -> Double {
        let challenges = getTodayChallenges()
        guard !challenges.isEmpty else { return 0 }

        let completed = challenges.filter { $0.isCompleted }.count
        return Double(completed) / Double(challenges.count)
    }
}
