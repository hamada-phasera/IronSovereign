import SwiftUI
import SwiftData

@main
struct IronSovereignApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(
                for: UserProfile.self,
                     WorkoutPlan.self,
                     WorkoutSession.self,
                     Exercise.self,
                     ExerciseSet.self,
                     CardioSession.self,
                     ProgressRecord.self
            )
        } catch {
            fatalError("SwiftData ModelContainer 初期化失敗: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(container)
    }
}
