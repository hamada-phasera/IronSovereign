import Foundation

struct CardioPlan {
    let cardioType: CardioType
    let durationMinutes: Int
    let heartRateLow: Int
    let heartRateHigh: Int
    let notes: String
}

class CardioPlanner {
    static let shared = CardioPlanner()

    func weeklyCardioPlan(
        trainingDaysPerWeek: Int,
        goal: TrainingGoal,
        weekNumber: Int
    ) -> [CardioPlan] {
        guard goal == .cutting else { return [] }

        var plans: [CardioPlan] = []

        // 筋トレ後 インクラインウォーク（脚の日以外）
        let postWorkoutSessions = max(trainingDaysPerWeek - 1, 1)
        for _ in 0..<postWorkoutSessions {
            plans.append(CardioPlan(
                cardioType: .inclineWalk,
                durationMinutes: weekNumber < 4 ? 20 : 25,
                heartRateLow: 130, heartRateHigh: 140,
                notes: "筋トレ後に実施。傾斜10-15%、速度5.5-6.5km/h"
            ))
        }

        // 週1回HIIT（週4週以降）
        if weekNumber >= 4 && trainingDaysPerWeek >= 3 {
            plans.append(CardioPlan(
                cardioType: .hiitTreadmill,
                durationMinutes: 15,
                heartRateLow: 160, heartRateHigh: 180,
                notes: "週1回まで。脚トレの日は避ける"
            ))
        }

        return plans
    }
}
