import SwiftData
import Foundation

@Model
final class ProgressRecord {
    var id: String
    var recordDate: Date
    var bodyWeight: Float?
    var exerciseId: String?
    var exerciseName: String?
    var maxWeight: Float
    var maxReps: Int
    var estimatedOneRepMax: Float
    var totalVolume: Float
    var sessionId: String?

    init(recordDate: Date, bodyWeight: Float? = nil,
         exerciseId: String? = nil, exerciseName: String? = nil,
         maxWeight: Float = 0, maxReps: Int = 0,
         estimatedOneRepMax: Float = 0, totalVolume: Float = 0,
         sessionId: String? = nil) {
        self.id = UUID().uuidString
        self.recordDate = recordDate
        self.bodyWeight = bodyWeight
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.maxWeight = maxWeight
        self.maxReps = maxReps
        self.estimatedOneRepMax = estimatedOneRepMax
        self.totalVolume = totalVolume
        self.sessionId = sessionId
    }
}
