import SwiftData
import Foundation

@Model
final class WorkoutPlan {
    var id: String
    var splitType: SplitType
    var weekStartDate: Date
    var isAIOptimized: Bool
    var source: String   // "rule_engine" or "claude_api"
    var createdAt: Date

    @Relationship(deleteRule: .cascade)
    var sessions: [WorkoutSession] = []

    init(splitType: SplitType, weekStartDate: Date, isAIOptimized: Bool = false) {
        self.id = UUID().uuidString
        self.splitType = splitType
        self.weekStartDate = weekStartDate
        self.isAIOptimized = isAIOptimized
        self.source = isAIOptimized ? "claude_api" : "rule_engine"
        self.createdAt = Date()
    }

    var completedSessionsCount: Int {
        sessions.filter { $0.isCompleted }.count
    }

    var weeklyCompletionRate: Double {
        guard !sessions.isEmpty else { return 0 }
        return Double(completedSessionsCount) / Double(sessions.count)
    }
}
