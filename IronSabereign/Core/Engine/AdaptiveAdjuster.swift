import Foundation
import SwiftData

class AdaptiveAdjuster {
    static let shared = AdaptiveAdjuster()
    private let ruleEngine = RuleEngine.shared

    /// 現在のセット結果に基づいて残りのセットを調整
    func adjustRemainingSet(
        completedSet: ExerciseSet,
        status: SetStatus,
        remainingSetCount: Int,
        exerciseEquipmentType: EquipmentType,
        exerciseRestSeconds: Int
    ) -> WeightRecommendation? {
        guard remainingSetCount > 0 else { return nil }

        switch status {
        case .failed:
            return ruleEngine.adjustForFailure(
                targetWeight: completedSet.targetWeight,
                targetReps: completedSet.targetReps,
                remainingSets: remainingSetCount,
                currentRestSeconds: exerciseRestSeconds,
                equipmentType: exerciseEquipmentType
            )
        case .completed:
            // 同一セッション内では重量維持（プログレッシブオーバーロードは次週）
            return WeightRecommendation(
                weight: completedSet.targetWeight,
                reps: completedSet.targetReps,
                sets: remainingSetCount,
                restSeconds: exerciseRestSeconds
            )
        default:
            return nil
        }
    }

    /// 前回セッションとの比較から次回推奨を生成
    func nextSessionRecommendation(
        exerciseId: String,
        previousSets: [ExerciseSet],
        optimalSets: Int,
        restSeconds: Int,
        equipmentType: EquipmentType
    ) -> WeightRecommendation {
        guard !previousSets.isEmpty else {
            // 履歴なし → デフォルト重量を使用
            return WeightRecommendation(
                weight: 20.0, reps: 8, sets: optimalSets, restSeconds: restSeconds
            )
        }

        let workSets = previousSets.filter { !$0.isWarmup }
        let allCompleted = workSets.allSatisfy { $0.status == .completed }
        let bestSet = workSets.max(by: { $0.actualWeight < $1.actualWeight })

        return ruleEngine.progressiveOverload(
            lastWeight: bestSet?.actualWeight ?? 20.0,
            lastReps: bestSet?.actualReps ?? 8,
            wasCompleted: allCompleted,
            optimalSets: optimalSets,
            restSeconds: restSeconds,
            equipmentType: equipmentType
        )
    }
}
