import Foundation

struct WeightRecommendation {
    let weight: Float
    let reps: Int
    let sets: Int
    let restSeconds: Int
    let note: String?

    init(weight: Float, reps: Int, sets: Int, restSeconds: Int, note: String? = nil) {
        self.weight = weight
        self.reps = reps
        self.sets = sets
        self.restSeconds = restSeconds
        self.note = note
    }
}

class RuleEngine {
    static let shared = RuleEngine()

    /// ベンチプレス1RMを基準とした各種目の重量比率
    static let weightRatios: [String: Float] = [
        "bench_press":          1.0,
        "incline_db_press":     0.35,
        "overhead_press":       0.65,
        "lateral_raise":        0.10,
        "triceps_pushdown":     0.30,
        "deadlift":             1.25,
        "lat_pulldown":         0.70,
        "seated_row":           0.65,
        "face_pull":            0.20,
        "barbell_curl":         0.40,
        "squat":                1.10,
        "leg_press":            1.80,
        "rdl":                  0.80,
        "leg_curl":             0.35,
        "calf_raise":           1.20,
        "cable_crunch":         0.45,
    ]

    /// 目標と動作パターンに応じた最適レップ・セット・インターバル
    func optimalRange(for goal: TrainingGoal, movement: MovementPattern) -> (reps: ClosedRange<Int>, sets: Int, restSec: Int) {
        switch (goal, movement) {
        case (.cutting, .horizontalPush), (.cutting, .verticalPush),
             (.cutting, .squat), (.cutting, .hipHinge):
            return (6...8, 4, 120)
        case (.cutting, .isolation):
            return (12...15, 3, 60)
        case (.cutting, _):
            return (8...10, 3, 90)
        case (.bulking, .horizontalPush), (.bulking, .verticalPush),
             (.bulking, .squat), (.bulking, .hipHinge):
            return (8...12, 4, 90)
        case (.bulking, .isolation):
            return (12...20, 3, 60)
        case (.strength, _):
            return (3...5, 5, 180)
        default:
            return (8...12, 3, 90)
        }
    }

    /// 初回重量推定（体重 + 経験レベル + 性別 + 種目比率）
    func initialWeight(
        for exerciseId: String,
        profile: UserProfile,
        exerciseData: ExerciseJSON
    ) -> Float {
        let baseWeight: Float
        switch profile.experienceLevel {
        case .beginner:
            baseWeight = profile.gender == .male ? exerciseData.defaultWeightMale : exerciseData.defaultWeightFemale
        case .intermediate:
            let factor: Float = 1.4
            let base = profile.gender == .male ? exerciseData.defaultWeightMale : exerciseData.defaultWeightFemale
            baseWeight = base * factor
        case .advanced:
            let factor: Float = 2.0
            let base = profile.gender == .male ? exerciseData.defaultWeightMale : exerciseData.defaultWeightFemale
            baseWeight = base * factor
        }
        // 5kg単位に丸める（バーベル）、2.5kg単位（ダンベル）
        if exerciseData.equipmentType == "dumbbell" {
            return (baseWeight / 2.5).rounded() * 2.5
        }
        return (baseWeight / 5.0).rounded() * 5.0
    }

    /// 未達成時のアダプティブ調整（5%減 + インターバル30秒追加）
    func adjustForFailure(
        targetWeight: Float,
        targetReps: Int,
        remainingSets: Int,
        currentRestSeconds: Int,
        equipmentType: EquipmentType
    ) -> WeightRecommendation {
        let reducedWeight = targetWeight * 0.95
        let roundedWeight: Float
        if equipmentType == .dumbbell {
            roundedWeight = (reducedWeight / 2.5).rounded(.down) * 2.5
        } else {
            roundedWeight = (reducedWeight / 5.0).rounded(.down) * 5.0
        }
        let adjustedReps = max(targetReps - 2, 3)
        return WeightRecommendation(
            weight: max(roundedWeight, equipmentType == .dumbbell ? 2.5 : 5.0),
            reps: adjustedReps,
            sets: remainingSets,
            restSeconds: currentRestSeconds + 30,
            note: "未達成のため重量を調整しました"
        )
    }

    /// プログレッシブオーバーロード（達成時の次回推奨）
    func progressiveOverload(
        lastWeight: Float,
        lastReps: Int,
        wasCompleted: Bool,
        optimalSets: Int,
        restSeconds: Int,
        equipmentType: EquipmentType
    ) -> WeightRecommendation {
        guard wasCompleted else {
            return WeightRecommendation(
                weight: lastWeight, reps: lastReps,
                sets: optimalSets, restSeconds: restSeconds,
                note: "前回未達成 — 同重量で再チャレンジ"
            )
        }
        let increment: Float = equipmentType == .dumbbell ? 1.0 : 2.5
        return WeightRecommendation(
            weight: lastWeight + increment,
            reps: lastReps,
            sets: optimalSets,
            restSeconds: restSeconds,
            note: "+\(increment)kg 増量"
        )
    }
}
