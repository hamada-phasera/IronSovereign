import SwiftUI
import SwiftData

@Observable
class WorkoutViewModel {
    var session: WorkoutSession
    var currentExerciseId: String = ""
    var currentSetIndex: Int = 0
    var isResting: Bool = false
    var restSecondsRemaining: Int = 0
    var restTotalSeconds: Int = 90
    var showCompletionAnimation: Bool = false
    var completionMessage: String = ""
    var sessionCompleted: Bool = false
    var sessionStartTime: Date = Date()

    private var restTimer: Timer?
    private let adjuster = AdaptiveAdjuster.shared
    private let db = ExerciseDatabase.shared

    // グループ化: exerciseId → [ExerciseSet]（PlanGeneratorの生成順を維持）
    var exerciseGroups: [(id: String, name: String, sets: [ExerciseSet])] {
        let workSets = session.exerciseSets.filter { !$0.isWarmup }

        // exerciseId の初出インデックスで種目順を決定し、その中でsetNumberでセットを並べる
        var result: [(id: String, name: String, sets: [ExerciseSet])] = []
        var seen: [String] = []
        for s in workSets.sorted(by: { $0.setNumber < $1.setNumber }) {
            if !seen.contains(s.exerciseId) {
                seen.append(s.exerciseId)
                let groupSets = workSets
                    .filter { $0.exerciseId == s.exerciseId }
                    .sorted { $0.setNumber < $1.setNumber }
                result.append((id: s.exerciseId, name: s.exerciseName, sets: groupSets))
            }
        }
        return result
    }

    var currentGroup: (id: String, name: String, sets: [ExerciseSet])? {
        exerciseGroups.first { $0.id == currentExerciseId }
    }

    var currentSet: ExerciseSet? {
        currentGroup?.sets.first { $0.status == .pending }
    }

    var allExerciseSetsCompleted: Bool {
        session.exerciseSets.filter { !$0.isWarmup }
            .allSatisfy { $0.status != .pending }
    }

    var completedExerciseCount: Int {
        exerciseGroups.filter { group in
            group.sets.allSatisfy { $0.status != .pending }
        }.count
    }

    init(session: WorkoutSession) {
        self.session = session
        sessionStartTime = Date()
        if let firstGroup = session.exerciseSets
            .filter({ !$0.isWarmup })
            .sorted(by: { $0.setNumber < $1.setNumber })
            .first {
            currentExerciseId = firstGroup.exerciseId
        }
    }

    // MARK: - セット完了

    func completeSet(_ set: ExerciseSet, status: SetStatus, context: ModelContext) {
        set.status = status
        set.actualWeight = set.targetWeight
        set.actualReps = status == .completed ? set.targetReps : max(set.targetReps - 2, 1)
        set.completedAt = Date()

        // 未達成の場合 → 残りセットを自動調整
        if status == .failed, let group = currentGroup {
            let remainingSets = group.sets.filter { $0.status == .pending }
            if let exData = db.exercise(by: group.id),
               let equipType = EquipmentType(rawValue: exData.equipmentType) {
                let adj = adjuster.adjustRemainingSet(
                    completedSet: set,
                    status: .failed,
                    remainingSetCount: remainingSets.count,
                    exerciseEquipmentType: equipType,
                    exerciseRestSeconds: exData.restSeconds
                )
                if let adj {
                    for s in remainingSets {
                        s.targetWeight = adj.weight
                        s.targetReps = adj.reps
                    }
                    startRest(seconds: adj.restSeconds)
                }
            }
        } else if status == .completed {
            let restSec = db.exercise(by: currentExerciseId)?.restSeconds ?? 90
            startRest(seconds: restSec)
        }

        // 種目クリア判定
        if let group = currentGroup, group.sets.allSatisfy({ $0.status != .pending }) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.showExerciseCompleted(name: group.name)
                self.advanceToNextExercise()
            }
        }

        try? context.save()

        if allExerciseSetsCompleted {
            finishSession(context: context)
        }
    }

    private func advanceToNextExercise() {
        guard let current = exerciseGroups.firstIndex(where: { $0.id == currentExerciseId }),
              current + 1 < exerciseGroups.count else { return }
        currentExerciseId = exerciseGroups[current + 1].id
        currentSetIndex = 0
    }

    // MARK: - インターバルタイマー

    func startRest(seconds: Int) {
        stopRest()
        restTotalSeconds = seconds
        restSecondsRemaining = seconds
        isResting = true
        restTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.restSecondsRemaining > 0 {
                self.restSecondsRemaining -= 1
            } else {
                self.stopRest()
            }
        }
    }

    func stopRest() {
        restTimer?.invalidate()
        restTimer = nil
        isResting = false
    }

    // MARK: - アニメーション

    private func showExerciseCompleted(name: String) {
        completionMessage = name
        showCompletionAnimation = true
    }

    // MARK: - セッション完了

    private func finishSession(context: ModelContext) {
        session.isCompleted = true
        session.completedDate = Date()
        session.totalDurationSeconds = Int(Date().timeIntervalSince(sessionStartTime))

        // 進捗レコードを生成
        let records = ProgressCalculator.shared.buildProgressRecords(from: session, bodyWeight: nil)
        for r in records { context.insert(r) }

        try? context.save()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.sessionCompleted = true
        }
    }
}
