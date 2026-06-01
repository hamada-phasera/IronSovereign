import Foundation

enum MuscleGroup: String, Codable, CaseIterable {
    case chest, back, shoulders, biceps, triceps
    case quads, hamstrings, glutes, calves
    case abs, forearms, traps
    case fullBody, cardio

    var displayName: String {
        switch self {
        case .chest: return "胸"
        case .back: return "背中"
        case .shoulders: return "肩"
        case .biceps: return "二頭"
        case .triceps: return "三頭"
        case .quads: return "大腿四頭筋"
        case .hamstrings: return "ハムストリング"
        case .glutes: return "臀部"
        case .calves: return "ふくらはぎ"
        case .abs: return "腹筋"
        case .forearms: return "前腕"
        case .traps: return "僧帽筋"
        case .fullBody: return "全身"
        case .cardio: return "有酸素"
        }
    }
}

enum EquipmentType: String, Codable {
    case barbell, dumbbell, machine, cable
    case bodyweight, cardioMachine

    var displayName: String {
        switch self {
        case .barbell: return "バーベル"
        case .dumbbell: return "ダンベル"
        case .machine: return "マシン"
        case .cable: return "ケーブル"
        case .bodyweight: return "自重"
        case .cardioMachine: return "有酸素マシン"
        }
    }
}

enum MovementPattern: String, Codable {
    case horizontalPush, horizontalPull
    case verticalPush, verticalPull
    case hipHinge, squat, lunge
    case isolation, carry, cardio
}

enum TrainingGoal: String, Codable {
    case cutting      // 減量
    case bulking      // 筋肥大
    case strength     // 筋力向上

    var displayName: String {
        switch self {
        case .cutting: return "減量"
        case .bulking: return "筋肥大"
        case .strength: return "筋力向上"
        }
    }
}

enum ExperienceLevel: String, Codable {
    case beginner     // 初心者
    case intermediate // 中級者
    case advanced     // 上級者

    var displayName: String {
        switch self {
        case .beginner: return "初心者"
        case .intermediate: return "中級者"
        case .advanced: return "上級者"
        }
    }
}

enum Gender: String, Codable {
    case male, female

    var displayName: String {
        switch self {
        case .male: return "男性"
        case .female: return "女性"
        }
    }
}

enum SetStatus: String, Codable {
    case pending    // 未実施
    case completed  // 達成
    case failed     // 未達成
    case skipped    // スキップ
}

enum SplitType: String, Codable {
    case pushPullLegs = "PPL"
    case upperLower   = "UL"
    case fullBody     = "FB"
}

enum SessionType: String, Codable {
    case push, pull, legs, upper, lower, fullBody
    case cardioOnly

    var displayName: String {
        switch self {
        case .push: return "PUSH DAY"
        case .pull: return "PULL DAY"
        case .legs: return "LEGS DAY"
        case .upper: return "UPPER DAY"
        case .lower: return "LOWER DAY"
        case .fullBody: return "FULL BODY"
        case .cardioOnly: return "CARDIO"
        }
    }

    var primaryMuscles: String {
        switch self {
        case .push: return "胸・肩・三頭"
        case .pull: return "背中・二頭"
        case .legs: return "脚・腹"
        case .upper: return "上半身"
        case .lower: return "下半身"
        case .fullBody: return "全身"
        case .cardioOnly: return "有酸素"
        }
    }
}

enum CardioType: String, Codable {
    case inclineWalk   = "incline_walk"
    case cycling       = "cycling"
    case hiitTreadmill = "hiit_treadmill"
    case elliptical    = "elliptical"

    var displayName: String {
        switch self {
        case .inclineWalk: return "インクラインウォーク"
        case .cycling: return "エアロバイク"
        case .hiitTreadmill: return "HIIT（トレッドミル）"
        case .elliptical: return "エリプティカル"
        }
    }

    var isHIIT: Bool { self == .hiitTreadmill }
}
