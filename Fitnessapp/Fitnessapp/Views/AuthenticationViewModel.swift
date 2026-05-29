import Foundation

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var authMode: AuthMode = .login
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    func submit() async -> (AppUser, UserFitnessProfile?)? {
        guard validateInput() else {
            return nil
        }

        isLoading = true
        defer { isLoading = false }

        let user = AppUser(
            id: UUID().uuidString,
            username: displayName,
            email: normalizedEmail
        )
        return (user, createDefaultProfile(for: user))
    }

    func continueWithGoogle() async -> (AppUser, UserFitnessProfile?)? {
        errorMessage = "Google login is disabled while Firebase is paused."
        return nil
    }

    private var normalizedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private var displayName: String {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        if authMode == .register && !trimmedUsername.isEmpty {
            return trimmedUsername
        }

        return normalizedEmail.components(separatedBy: "@").first?.isEmpty == false
            ? normalizedEmail.components(separatedBy: "@").first ?? "Fitness User"
            : "Fitness User"
    }

    private func validateInput() -> Bool {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

        if authMode == .register && trimmedUsername.isEmpty {
            errorMessage = "Enter a username to create your account."
            return false
        }

        if normalizedEmail.isEmpty || !normalizedEmail.contains("@") {
            errorMessage = "Enter a valid email address."
            return false
        }

        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters."
            return false
        }

        errorMessage = nil
        return true
    }

    private func createDefaultProfile(for user: AppUser) -> UserFitnessProfile {
        UserFitnessProfile(
            userId: user.id,
            username: user.username,
            email: user.email,
            dailyCalorieTarget: 500,
            dailyWorkoutDurationMinutes: 30,
            weightKg: 70,
            age: 20,
            fitnessLevel: .beginner,
            onboardingCompleted: false,
            createdAt: nil,
            updatedAt: nil
        )
    }
}
