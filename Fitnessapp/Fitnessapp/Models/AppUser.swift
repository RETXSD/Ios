import Foundation

struct AppUser: Identifiable, Codable, Equatable {
    let id: String
    var username: String
    var email: String
}
