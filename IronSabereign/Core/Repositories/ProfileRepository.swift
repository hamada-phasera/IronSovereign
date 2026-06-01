import SwiftData
import Foundation

class ProfileRepository {
    static let shared = ProfileRepository()

    func currentProfile(context: ModelContext) -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfile>(
            sortBy: [SortDescriptor<UserProfile>(\.createdAt)]
        )
        return try? context.fetch(descriptor).first
    }
}
