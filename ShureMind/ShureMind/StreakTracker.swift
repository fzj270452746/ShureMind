import Foundation

// Training streak tracker manager
class StreakTracker {
    static let shared = StreakTracker()
    private let userDefaults = UserDefaults.standard

    private let currentStreakKey = "currentStreak"
    private let longestStreakKey = "longestStreak"
    private let lastTrainingDateKey = "lastTrainingDate"
    private let totalTrainingDaysKey = "totalTrainingDays"

    private init() {}

    // Record today's training
    func recordTrainingToday() {
        let today = Calendar.current.startOfDay(for: Date())

        if let lastDate = userDefaults.object(forKey: lastTrainingDateKey) as? Date {
            let lastDay = Calendar.current.startOfDay(for: lastDate)

            // If already recorded today, return directly
            if lastDay == today {
                return
            }

            // Calculate day difference
            let daysDifference = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if daysDifference == 1 {
                // Consecutive training, increment streak
                incrementStreak()
            } else if daysDifference > 1 {
                // Interrupted, reset streak
                resetStreak()
            }
        } else {
            // First training
            setStreak(1)
        }

        // Update last training date
        userDefaults.set(today, forKey: lastTrainingDateKey)

        // Increment total training days
        let totalDays = userDefaults.integer(forKey: totalTrainingDaysKey)
        userDefaults.set(totalDays + 1, forKey: totalTrainingDaysKey)

        // Update achievements
        updateStreakAchievements()
    }

    // Get current streak
    func getCurrentStreak() -> Int {
        checkStreakValidity()
        return userDefaults.integer(forKey: currentStreakKey)
    }

    // Get longest streak
    func getLongestStreak() -> Int {
        return userDefaults.integer(forKey: longestStreakKey)
    }

    // Get total training days
    func getTotalTrainingDays() -> Int {
        return userDefaults.integer(forKey: totalTrainingDaysKey)
    }

    // Check streak validity
    private func checkStreakValidity() {
        guard let lastDate = userDefaults.object(forKey: lastTrainingDateKey) as? Date else {
            return
        }

        let today = Calendar.current.startOfDay(for: Date())
        let lastDay = Calendar.current.startOfDay(for: lastDate)
        let daysDifference = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0

        // If no training for more than 1 day, reset streak
        if daysDifference > 1 {
            resetStreak()
        }
    }

    // Increment streak
    private func incrementStreak() {
        let current = userDefaults.integer(forKey: currentStreakKey)
        let newStreak = current + 1
        setStreak(newStreak)

        // Update longest streak
        let longest = userDefaults.integer(forKey: longestStreakKey)
        if newStreak > longest {
            userDefaults.set(newStreak, forKey: longestStreakKey)
        }
    }

    // Set streak
    private func setStreak(_ value: Int) {
        userDefaults.set(value, forKey: currentStreakKey)
    }

    // Reset streak
    private func resetStreak() {
        setStreak(1)
    }

    // Update streak-related achievements
    private func updateStreakAchievements() {
        let currentStreak = getCurrentStreak()

        // Update 7-day streak achievement
        if currentStreak >= 7 {
            AchievementSystem.shared.updateAchievement(id: "week_streak", value: currentStreak)
        }

        // Update 30-day streak achievement
        if currentStreak >= 30 {
            AchievementSystem.shared.updateAchievement(id: "month_streak", value: currentStreak)
        }
    }

    // Get streak status description
    func getStreakStatus() -> String {
        let streak = getCurrentStreak()

        if streak == 0 {
            return "Start your training journey!"
        } else if streak == 1 {
            return "Great start!"
        } else if streak < 7 {
            return "Keep it up!"
        } else if streak < 30 {
            return "You're doing great!"
        } else {
            return "You're a true master!"
        }
    }

    // Get next milestone
    func getNextMilestone() -> (days: Int, description: String)? {
        let streak = getCurrentStreak()

        let milestones = [
            (7, "One Week Streak"),
            (14, "Two Week Streak"),
            (30, "One Month Streak"),
            (60, "Two Month Streak"),
            (100, "100 Day Streak"),
            (365, "One Year Streak")
        ]

        for milestone in milestones {
            if streak < milestone.0 {
                return milestone
            }
        }

        return nil
    }
}
