import Foundation

class ProgressCalculator {
    static let shared = ProgressCalculator()

    /// Epley式で推定1RMを計算
    func estimatedOneRepMax(weight: Float, reps: Int) -> Float {
        guard reps > 0 else { return weight }
        if reps == 1 { return weight }
        return weight * (1 + Float(reps) / 30.0)
    }

    /// セッションから進捗レコードを生成
    func buildProgressRecords(from session: WorkoutSession, bodyWeight: Float?) -> [ProgressRecord] {
        var records: [ProgressRecord] = []

        // 体重記録
        if let bw = bodyWeight {
            records.append(ProgressRecord(
                recordDate: session.completedDate ?? Date(),
                bodyWeight: bw
            ))
        }

        // 種目ごとの最大重量・1RM記録
        let grouped = Dictionary(grouping: session.exerciseSets.filter { !$0.isWarmup && $0.status == .completed }) { $0.exerciseId }
        for (exerciseId, sets) in grouped {
            guard let bestSet = sets.max(by: { $0.estimatedOneRepMax < $1.estimatedOneRepMax }) else { continue }
            let totalVol = sets.reduce(0) { $0 + $1.volume }
            records.append(ProgressRecord(
                recordDate: session.completedDate ?? Date(),
                exerciseId: exerciseId,
                exerciseName: bestSet.exerciseName,
                maxWeight: bestSet.actualWeight,
                maxReps: bestSet.actualReps,
                estimatedOneRepMax: bestSet.estimatedOneRepMax,
                totalVolume: totalVol,
                sessionId: session.id
            ))
        }
        return records
    }
}
