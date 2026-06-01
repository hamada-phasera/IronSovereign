import SwiftData
import Foundation

@Model
final class ExerciseSet: Identifiable {
    var id: String
    var setNumber: Int
    var targetWeight: Float
    var targetReps: Int
    var actualWeight: Float
    var actualReps: Int
    var status: SetStatus
    var isWarmup: Bool
    var completedAt: Date?
    var exerciseId: String  // reference to Exercise.id
    var exerciseName: String // denormalized for display

    init(setNumber: Int, targetWeight: Float, targetReps: Int,
         exerciseId: String, exerciseName: String, isWarmup: Bool = false) {
        self.id = UUID().uuidString
        self.setNumber = setNumber
        self.targetWeight = targetWeight
        self.targetReps = targetReps
        self.actualWeight = targetWeight
        self.actualReps = 0
        self.status = .pending
        self.isWarmup = isWarmup
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
    }

    // Epley式で推定1RMを計算
    var estimatedOneRepMax: Float {
        guard actualReps > 0, actualWeight > 0 else { return 0 }
        return actualWeight * (1 + Float(actualReps) / 30.0)
    }

    var volume: Float { actualWeight * Float(actualReps) }
}
