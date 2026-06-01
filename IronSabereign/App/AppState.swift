import SwiftUI
import SwiftData

@Observable
class AppState {
    var hasCompletedOnboarding: Bool = false
    var currentUserProfile: UserProfile?
    var activeWorkoutSession: WorkoutSession?

    static let shared = AppState()

    private init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }

    func completeOnboarding(profile: UserProfile) {
        currentUserProfile = profile
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}

struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var appState = AppState.shared

    var body: some View {
        Group {
            if profiles.isEmpty {
                OnboardingView()
            } else {
                DashboardView()
                    .onAppear {
                        appState.currentUserProfile = profiles.first
                    }
            }
        }
        .environment(appState)
        .preferredColorScheme(.dark)
    }
}
