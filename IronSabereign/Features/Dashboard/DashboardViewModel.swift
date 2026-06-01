import SwiftUI
import SwiftData

@Observable
class DashboardViewModel {
    var todaySession: WorkoutSession?
    var currentPlan: WorkoutPlan?
    var weeklyCompletionRate: Double = 0
    var recentWeightChange: Float = 0
    var isLoading = false
    var quoteOfDay: String = ""

    private let quotes = [
        "汝の鍛錬、今日もまた始まる",
        "鋼鉄は鍛えられて初めて輝く",
        "限界とは、挑む者に与えられた贈り物",
        "今日の苦しみは、明日の力となる",
        "征服されるのを待つ重量が、そこにある",
        "休息は罪ではない。それもまた鍛錬の一部",
    ]

    func loadData(context: ModelContext) {
        isLoading = true
        todaySession = WorkoutRepository.shared.todaySession(context: context)
        currentPlan = WorkoutRepository.shared.currentWeekPlan(context: context)
        weeklyCompletionRate = currentPlan?.weeklyCompletionRate ?? 0

        let dayIndex = (Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1) - 1
        quoteOfDay = quotes[dayIndex % quotes.count]

        let bodyRecords = ProgressRepository.shared.bodyWeightRecords(context: context)
        if bodyRecords.count >= 2 {
            let latest = bodyRecords.suffix(7).compactMap { $0.bodyWeight }
            let prior = bodyRecords.dropLast(7).suffix(7).compactMap { $0.bodyWeight }
            if let la = latest.average, let pa = prior.average {
                recentWeightChange = la - pa
            }
        }
        isLoading = false
    }

    func generatePlanIfNeeded(profile: UserProfile, context: ModelContext) {
        guard currentPlan == nil else { return }
        let plan = PlanGenerator.shared.generateWeeklyPlan(
            profile: profile,
            weekStartDate: Date().startOfWeek,
            context: context
        )
        profile.workoutPlans.append(plan)
        try? context.save()
        currentPlan = plan
        todaySession = WorkoutRepository.shared.todaySession(context: context)
    }
}

extension Array where Element == Float {
    var average: Float? {
        guard !isEmpty else { return nil }
        return reduce(0, +) / Float(count)
    }
}
