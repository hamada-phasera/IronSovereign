import SwiftUI
import SwiftData

enum TimePeriod: String, CaseIterable {
    case week   = "週"
    case month  = "月"
    case quarter = "3ヶ月"
    case all    = "全期間"

    var days: Int? {
        switch self {
        case .week:    return 7
        case .month:   return 30
        case .quarter: return 90
        case .all:     return nil
        }
    }
}

@Observable
class ProgressViewModel {
    var selectedPeriod: TimePeriod = .month
    var bodyWeightRecords: [ProgressRecord] = []
    var exerciseRecords: [String: [ProgressRecord]] = [:]
    var weeklyVolumes: [(Date, Float)] = []
    var availableExercises: [String] = []
    var selectedExerciseId: String = "bench_press"

    func loadData(context: ModelContext) {
        bodyWeightRecords = filteredRecords(
            ProgressRepository.shared.bodyWeightRecords(context: context)
        )
        weeklyVolumes = ProgressRepository.shared.weeklyVolume(context: context, weeks: 12)

        availableExercises = ["bench_press", "squat", "deadlift", "overhead_press",
                              "lat_pulldown", "barbell_curl"]
        for exId in availableExercises {
            let records = ProgressRepository.shared.records(for: exId, context: context)
            exerciseRecords[exId] = filteredRecords(records)
        }
    }

    var currentExerciseRecords: [ProgressRecord] {
        exerciseRecords[selectedExerciseId] ?? []
    }

    var currentExerciseName: String {
        ExerciseDatabase.shared.exercise(by: selectedExerciseId)?.name ?? selectedExerciseId
    }

    private func filteredRecords(_ records: [ProgressRecord]) -> [ProgressRecord] {
        guard let days = selectedPeriod.days else { return records }
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        return records.filter { $0.recordDate >= cutoff }
    }
}

