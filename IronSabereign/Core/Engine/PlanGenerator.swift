import Foundation
import SwiftData

class PlanGenerator {
    static let shared = PlanGenerator()
    private let ruleEngine = RuleEngine.shared
    private let db = ExerciseDatabase.shared

    /// 週間トレーニングプランをルールベースで生成
    func generateWeeklyPlan(
        profile: UserProfile,
        weekStartDate: Date,
        context: ModelContext
    ) -> WorkoutPlan {
        let plan = WorkoutPlan(splitType: .pushPullLegs, weekStartDate: weekStartDate)
        context.insert(plan)

        // PPLを毎日ローテーション（週7日分生成）
        let cycle: [SessionType] = [.push, .pull, .legs]
        let calendar = Calendar.current
        for dayIndex in 0..<7 {
            let sessionDate = calendar.date(byAdding: .day, value: dayIndex, to: weekStartDate) ?? weekStartDate
            let sessionType = cycle[dayIndex % cycle.count]
            let session = generateSession(
                dayNumber: dayIndex + 1,
                sessionType: sessionType,
                scheduledDate: sessionDate,
                profile: profile,
                context: context
            )
            plan.sessions.append(session)
        }

        return plan
    }

    private func generateSession(
        dayNumber: Int,
        sessionType: SessionType,
        scheduledDate: Date,
        profile: UserProfile,
        context: ModelContext
    ) -> WorkoutSession {
        let session = WorkoutSession(dayNumber: dayNumber, sessionType: sessionType, scheduledDate: scheduledDate)
        context.insert(session)

        let exercises = db.orderedExercises(for: sessionType)

        for exerciseData in exercises {
            guard let movement = MovementPattern(rawValue: exerciseData.movementPattern),
                  let _ = EquipmentType(rawValue: exerciseData.equipmentType)
            else { continue }

            let range = ruleEngine.optimalRange(for: profile.goal, movement: movement)
            let weight = ruleEngine.initialWeight(for: exerciseData.id, profile: profile, exerciseData: exerciseData)
            let targetReps = (range.reps.lowerBound + range.reps.upperBound) / 2

            // ウォームアップセット (コンパウンドのみ)
            if movement != .isolation && movement != .cardio {
                let warmup = ExerciseSet(
                    setNumber: 0,
                    targetWeight: weight * 0.6,
                    targetReps: 8,
                    exerciseId: exerciseData.id,
                    exerciseName: exerciseData.name,
                    isWarmup: true
                )
                context.insert(warmup)
                session.exerciseSets.append(warmup)
            }

            // ワークセット
            for setNum in 1...range.sets {
                let workSet = ExerciseSet(
                    setNumber: setNum,
                    targetWeight: weight,
                    targetReps: targetReps,
                    exerciseId: exerciseData.id,
                    exerciseName: exerciseData.name
                )
                context.insert(workSet)
                session.exerciseSets.append(workSet)
            }
        }

        // 有酸素セッションを追加（脚の日以外）
        if sessionType != .legs {
            let cardio = CardioSession(
                cardioType: .inclineWalk,
                targetDurationMin: 25,
                targetHeartRateLow: 130,
                targetHeartRateHigh: 140
            )
            context.insert(cardio)
            session.cardioSession = cardio
        }

        return session
    }
}

