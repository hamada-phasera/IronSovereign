import SwiftData
import Foundation

@Model
final class CardioSession {
    var id: String
    var cardioType: CardioType
    var targetDurationMin: Int
    var actualDurationMin: Int
    var intensity: String
    var targetHeartRateLow: Int
    var targetHeartRateHigh: Int
    var caloriesEstimated: Float
    var isCompleted: Bool
    var completedAt: Date?
    var notes: String?

    init(cardioType: CardioType, targetDurationMin: Int,
         targetHeartRateLow: Int, targetHeartRateHigh: Int) {
        self.id = UUID().uuidString
        self.cardioType = cardioType
        self.targetDurationMin = targetDurationMin
        self.actualDurationMin = 0
        self.intensity = "中強度"
        self.targetHeartRateLow = targetHeartRateLow
        self.targetHeartRateHigh = targetHeartRateHigh
        self.caloriesEstimated = Float(targetDurationMin) * 6.0
        self.isCompleted = false
    }
}
