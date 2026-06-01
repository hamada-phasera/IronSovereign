import Foundation

struct ExerciseData: Codable {
    let exercises: [ExerciseJSON]
    let cardioOptions: [CardioOptionJSON]
}

struct ExerciseJSON: Codable {
    let id: String
    let name: String
    let nameEn: String
    let muscleGroupPrimary: String
    let muscleGroupSecondary: String?
    let equipmentType: String
    let movementPattern: String
    let defaultWeightMale: Float
    let defaultWeightFemale: Float
    let optimalRepRangeLow: Int
    let optimalRepRangeHigh: Int
    let optimalSets: Int
    let restSeconds: Int
    let rpeTarget: Float
    let weightRatioToBench: Float
    let notes: String?
}

struct CardioOptionJSON: Codable {
    let id: String
    let name: String
    let type: String
    let defaultDurationMin: Int
    let targetHeartRateBPM: [Int]
    let caloriesPerMinEstimate: Float
    let notes: String?
}

class ExerciseDatabase {
    static let shared = ExerciseDatabase()
    private(set) var exercises: [ExerciseJSON] = []
    private(set) var cardioOptions: [CardioOptionJSON] = []

    private init() {
        loadData()
    }

    private func loadData() {
        guard let url = Bundle.main.url(forResource: "ExerciseData", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(ExerciseData.self, from: data)
        else {
            exercises = ExerciseDatabase.fallbackExercises()
            cardioOptions = ExerciseDatabase.fallbackCardioOptions()
            return
        }
        exercises = decoded.exercises
        cardioOptions = decoded.cardioOptions
    }

    func exercise(by id: String) -> ExerciseJSON? {
        exercises.first { $0.id == id }
    }

    func exercises(for sessionType: SessionType) -> [ExerciseJSON] {
        switch sessionType {
        case .push:
            return exercises.filter { ["bench_press","incline_db_press","overhead_press","lateral_raise","triceps_pushdown"].contains($0.id) }
        case .pull:
            return exercises.filter { ["deadlift","lat_pulldown","seated_row","face_pull","barbell_curl"].contains($0.id) }
        case .legs:
            return exercises.filter { ["squat","leg_press","rdl","leg_curl","calf_raise","cable_crunch"].contains($0.id) }
        default:
            return exercises
        }
    }

    // PPLスプリット順序を守るためのインデックス
    func orderedExercises(for sessionType: SessionType) -> [ExerciseJSON] {
        let ordered = exercises(for: sessionType)
        let order: [String]
        switch sessionType {
        case .push:
            order = ["bench_press","incline_db_press","overhead_press","lateral_raise","triceps_pushdown"]
        case .pull:
            order = ["deadlift","lat_pulldown","seated_row","face_pull","barbell_curl"]
        case .legs:
            order = ["squat","leg_press","rdl","leg_curl","calf_raise","cable_crunch"]
        default:
            return ordered
        }
        return order.compactMap { id in ordered.first { $0.id == id } }
    }

    static func fallbackExercises() -> [ExerciseJSON] {
        [
            ExerciseJSON(id: "bench_press", name: "ベンチプレス", nameEn: "Bench Press",
                        muscleGroupPrimary: "chest", muscleGroupSecondary: "triceps",
                        equipmentType: "barbell", movementPattern: "horizontalPush",
                        defaultWeightMale: 40, defaultWeightFemale: 20,
                        optimalRepRangeLow: 6, optimalRepRangeHigh: 8, optimalSets: 4,
                        restSeconds: 120, rpeTarget: 8.0, weightRatioToBench: 1.0,
                        notes: "肩甲骨を寄せてアーチを作る。"),
        ]
    }

    static func fallbackCardioOptions() -> [CardioOptionJSON] {
        [
            CardioOptionJSON(id: "incline_walk", name: "インクラインウォーク", type: "steady_state",
                            defaultDurationMin: 25, targetHeartRateBPM: [130, 140],
                            caloriesPerMinEstimate: 6.0, notes: "傾斜10-15%"),
        ]
    }
}
