import SwiftUI
import SwiftData

@Observable
class SettingsViewModel {
    var claudeAPIKey: String = ""
    var showAPIKeySaved = false
    var bodyWeightInput: Float = 70.0

    init() {
        claudeAPIKey = UserDefaults.standard.string(forKey: "claude_api_key") ?? ""
    }

    func saveAPIKey() {
        ClaudeAPIService.shared.setAPIKey(claudeAPIKey)
        showAPIKeySaved = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.showAPIKeySaved = false }
    }

    func updateBodyWeight(profile: UserProfile, context: ModelContext) {
        profile.bodyWeight = bodyWeightInput
        profile.updatedAt = Date()
        let record = ProgressRecord(recordDate: Date(), bodyWeight: bodyWeightInput)
        context.insert(record)
        try? context.save()
    }
}
