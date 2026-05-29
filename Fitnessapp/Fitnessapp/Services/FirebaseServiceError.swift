import Foundation

enum FirebaseServiceError: LocalizedError, Equatable {
    case firebaseSDKUnavailable
    case firebaseFunctionsUnavailable
    case googleSignInRequiresPresentationContext
    case userNotAuthenticated
    case missingAuthResult
    case invalidDocument(String)
    case invalidAIResponse

    var errorDescription: String? {
        switch self {
        case .firebaseSDKUnavailable:
            return "Firebase SDK packages are not configured for this target yet."
        case .firebaseFunctionsUnavailable:
            return "Firebase Functions is not configured for this target yet."
        case .googleSignInRequiresPresentationContext:
            return "Google Sign-In needs the UI layer to provide a presentation context or tokens."
        case .userNotAuthenticated:
            return "No authenticated Firebase user is available."
        case .missingAuthResult:
            return "Firebase Auth did not return a user."
        case .invalidDocument(let collection):
            return "Firestore returned an invalid document in \(collection)."
        case .invalidAIResponse:
            return "The AI backend returned a response the app could not decode."
        }
    }
}
