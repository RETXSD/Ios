import Foundation

final class UserProfileService {
    private var profiles: [String: UserFitnessProfile] = [:]

    func fetchProfile(userId: String) async throws -> UserFitnessProfile? {
        profiles[userId]
    }

    func saveProfile(_ profile: UserFitnessProfile) async throws {
        profiles[profile.userId] = profile
    }

    func markOnboardingComplete(userId: String) async throws {
        guard var profile = profiles[userId] else {
            return
        }

        profile.onboardingCompleted = true
        profile.updatedAt = Date.now
        profiles[userId] = profile
    }
}
