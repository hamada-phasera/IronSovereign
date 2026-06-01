import SwiftData
import Foundation

class ProgressRepository {
    static let shared = ProgressRepository()

    func records(for exerciseId: String, context: ModelContext) -> [ProgressRecord] {
        let descriptor = FetchDescriptor<ProgressRecord>(
            predicate: #Predicate { $0.exerciseId == exerciseId },
            sortBy: [SortDescriptor(\.recordDate)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func bodyWeightRecords(context: ModelContext) -> [ProgressRecord] {
        let descriptor = FetchDescriptor<ProgressRecord>(
            predicate: #Predicate { $0.bodyWeight != nil },
            sortBy: [SortDescriptor(\.recordDate)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func weeklyVolume(context: ModelContext, weeks: Int = 12) -> [(Date, Float)] {
        let cutoff = Calendar.current.date(byAdding: .weekOfYear, value: -weeks, to: Date())!
        let descriptor = FetchDescriptor<ProgressRecord>(
            predicate: #Predicate { $0.recordDate >= cutoff && $0.exerciseId != nil },
            sortBy: [SortDescriptor(\.recordDate)]
        )
        let records = (try? context.fetch(descriptor)) ?? []
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: records) { record in
            calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: record.recordDate))!
        }
        return grouped.map { ($0.key, $0.value.reduce(0) { $0 + $1.totalVolume }) }.sorted { $0.0 < $1.0 }
    }
}
