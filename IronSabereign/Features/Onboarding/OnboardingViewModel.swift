import SwiftUI
import SwiftData

@Observable
class OnboardingViewModel {
    var currentStep: Int = 0
    let totalSteps: Int = 7

    var name: String = ""
    var bodyWeightKg: Float = 70.0
    var gender: Gender = .male
    var experienceLevel: ExperienceLevel = .beginner
    var goal: TrainingGoal = .cutting
    var trainingDaysPerWeek: Int = 3

    var progress: Double { Double(currentStep) / Double(totalSteps - 1) }

    var canAdvance: Bool {
        switch currentStep {
        case 0: return !name.trimmingCharacters(in: .whitespaces).isEmpty
        case 1: return bodyWeightKg > 0
        default: return true
        }
    }

    func advance() {
        guard currentStep < totalSteps - 1 else { return }
        currentStep += 1
    }

    func back() {
        guard currentStep > 0 else { return }
        currentStep -= 1
    }

    func saveProfile(context: ModelContext) -> UserProfile {
        let profile = UserProfile(
            name: name.trimmingCharacters(in: .whitespaces),
            bodyWeight: bodyWeightKg,
            gender: gender,
            trainingDaysPerWeek: trainingDaysPerWeek,
            goal: goal,
            experienceLevel: experienceLevel
        )
        context.insert(profile)

        let plan = PlanGenerator.shared.generateWeeklyPlan(
            profile: profile,
            weekStartDate: Date().startOfWeek,
            context: context
        )
        profile.workoutPlans.append(plan)
        try? context.save()
        return profile
    }
}

