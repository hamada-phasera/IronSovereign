import SwiftData
import Foundation

@Model
final class WorkoutSession {
    var id: String
    var dayNumber: Int
    var sessionType: SessionType
    var primaryMuscles: String
    var scheduledDate: Date
    var completedDate: Date?
    var isCompleted: Bool
    var totalDurationSeconds: Int
    var notes: String?

    @Relationship(deleteRule: .cascade)
    var exerciseSets: [ExerciseSet] = []

    @Relationship(deleteRule: .cascade)
    var cardioSession: CardioSession?

    init(dayNumber: Int, sessionType: SessionType, scheduledDate: Date) {
        self.id = UUID().uuidString
        self.dayNumber = dayNumber
        self.sessionType = sessionType
        self.primaryMuscles = sessionType.primaryMuscles
        self.scheduledDate = scheduledDate
        self.isCompleted = false
        self.totalDurationSeconds = 0
    }

    var completionRate: Double {
        let workSets = exerciseSets.filter { !$0.isWarmup }
        guard !workSets.isEmpty else { return 0 }
        let completed = workSets.filter { $0.status == .completed }.count
        return Double(completed) / Double(workSets.count)
    }

    var totalVolume: Float {
        exerciseSets.reduce(0) { $0 + $1.volume }
    }
}
