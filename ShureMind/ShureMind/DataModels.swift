import Foundation

// Data model for Shulte Grid performance metrics
struct CognitiveMetrics: Codable {
    let gridDimension: Int
    let completionDuration: TimeInterval
    let timestamp: Date
    let accuracyRate: Double

    init(gridDimension: Int, completionDuration: TimeInterval, accuracyRate: Double = 1.0) {
        self.gridDimension = gridDimension
        self.completionDuration = completionDuration
        self.timestamp = Date()
        self.accuracyRate = accuracyRate
    }
}

// Data model for Picture Memory performance
struct RecollectionMetrics: Codable {
    let imageQuantity: Int
    let attemptsUsed: Int
    let isSuccessful: Bool
    let timestamp: Date

    init(imageQuantity: Int, attemptsUsed: Int, isSuccessful: Bool) {
        self.imageQuantity = imageQuantity
        self.attemptsUsed = attemptsUsed
        self.isSuccessful = isSuccessful
        self.timestamp = Date()
    }
}

// Data persistence manager
class PerformanceArchive {
    static let shared = PerformanceArchive()

    private let cognitiveKey = "neuralGridArchive"
    private let recollectionKey = "memorySequenceArchive"

    private init() {}

    // Save Shulte Grid record
    func archiveCognitiveSession(_ metrics: CognitiveMetrics) {
        var records = retrieveCognitiveHistory()
        records.append(metrics)

        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: cognitiveKey)
        }
    }

    // Retrieve Shulte Grid history
    func retrieveCognitiveHistory() -> [CognitiveMetrics] {
        guard let data = UserDefaults.standard.data(forKey: cognitiveKey),
              let records = try? JSONDecoder().decode([CognitiveMetrics].self, from: data) else {
            return []
        }
        return records
    }

    // Get best time for specific grid size
    func fetchOptimalDuration(forDimension dimension: Int) -> TimeInterval? {
        let records = retrieveCognitiveHistory().filter { $0.gridDimension == dimension }
        return records.map { $0.completionDuration }.min()
    }

    // Save Picture Memory record
    func archiveRecollectionSession(_ metrics: RecollectionMetrics) {
        var records = retrieveRecollectionHistory()
        records.append(metrics)

        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: recollectionKey)
        }
    }

    // Retrieve Picture Memory history
    func retrieveRecollectionHistory() -> [RecollectionMetrics] {
        guard let data = UserDefaults.standard.data(forKey: recollectionKey),
              let records = try? JSONDecoder().decode([RecollectionMetrics].self, from: data) else {
            return []
        }
        return records
    }
}
