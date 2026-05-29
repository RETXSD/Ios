import Foundation

enum AuthMode: String, CaseIterable, Identifiable {
    case login = "Login"
    case register = "Register"

    var id: String { rawValue }
}
