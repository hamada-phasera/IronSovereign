import SwiftData
import Foundation

@Model
final class UserProfile {
    @Attribute(.unique) var id: String
    var name: String
    var bodyWeight: Float
    var gender: Gender
    var trainingDaysPerWeek: Int
    var goal: TrainingGoal
    var experienceLevel: ExperienceLevel
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade)
    var workoutPlans: [WorkoutPlan] = []

    @Relationship(deleteRule: .cascade)
    var progressRecords: [ProgressRecord] = []

    init(
        name: String,
        bodyWeight: Float,
        gender: Gender,
        trainingDaysPerWeek: Int,
        goal: TrainingGoal,
        experienceLevel: ExperienceLevel
    ) {
        self.id = UUID().uuidString
        self.name = name
        self.bodyWeight = bodyWeight
        self.gender = gender
        self.trainingDaysPerWeek = trainingDaysPerWeek
        self.goal = goal
        self.experienceLevel = experienceLevel
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
