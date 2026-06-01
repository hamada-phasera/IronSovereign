import SwiftData
import Foundation

class WorkoutRepository {
    static let shared = WorkoutRepository()

    func currentWeekPlan(context: ModelContext) -> WorkoutPlan? {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let descriptor = FetchDescriptor<WorkoutPlan>(
            predicate: #Predicate { $0.weekStartDate >= startOfWeek },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try? context.fetch(descriptor).first
    }

    func todaySession(context: ModelContext) -> WorkoutSession? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.scheduledDate >= today && $0.scheduledDate < tomorrow && !$0.isCompleted }
        )
        return try? context.fetch(descriptor).first
    }

    func recentSessions(context: ModelContext, limit: Int = 12) -> [WorkoutSession] {
        var descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.isCompleted },
            sortBy: [SortDescriptor(\.completedDate, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return (try? context.fetch(descriptor)) ?? []
    }
}
