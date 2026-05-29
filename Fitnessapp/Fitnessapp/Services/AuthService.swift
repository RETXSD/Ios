import Foundation

final class AuthService {
    private var cachedUser: AppUser?

    func register(username: String, email: String, password: String) async throws -> AppUser {
        let user = AppUser(
            id: UUID().uuidString,
            username: username.isEmpty ? "Fitness User" : username,
            email: email
        )
        cachedUser = user
        return user
    }

    func login(email: String, password: String) async throws -> AppUser {
        let user = AppUser(
            id: UUID().uuidString,
            username: email.components(separatedBy: "@").first ?? "Fitness User",
            email: email
        )
        cachedUser = user
        return user
    }

    func loginWithGoogle() async throws -> AppUser {
        throw FirebaseServiceError.firebaseSDKUnavailable
    }

    func loginWithGoogle(idToken: String, accessToken: String) async throws -> AppUser {
        throw FirebaseServiceError.firebaseSDKUnavailable
    }

    func logout() throws {
        cachedUser = nil
    }

    func currentUser() -> AppUser? {
        cachedUser
    }
}
