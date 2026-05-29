import Foundation

enum FirebasePayloadMapper {
    static func appUser(from userId: String, username: String?, email: String?) -> AppUser {
        AppUser(
            id: userId,
            username: username?.isEmpty == false ? username! : "Fitness User",
            email: email ?? ""
        )
    }
}
