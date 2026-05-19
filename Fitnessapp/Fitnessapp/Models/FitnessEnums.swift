import Foundation

enum WorkoutCategory: String, CaseIterable, Identifiable {
    case strength = "Strength"
    case cardio = "Cardio"
    case mobility = "Mobility"
    case recovery = "Recovery"
    case mixed = "Mixed"

    var id: String { rawValue }
}

enum WorkoutDifficulty: String, CaseIterable, Identifiable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"

    var id: String { rawValue }
}

enum CalorieDataSource: String, CaseIterable, Identifiable {
    case healthKit = "Apple Health"
    case manual = "Manual"
    case preview = "Preview"

    var id: String { rawValue }
}

enum PermissionStatus: String, CaseIterable, Identifiable {
    case notDetermined = "Not Determined"
    case authorized = "Authorized"
    case denied = "Denied"
    case restricted = "Restricted"
    case unavailable = "Unavailable"

    var id: String { rawValue }
}

enum ExerciseFormIssue: String, CaseIterable, Identifiable {
    case kneesCavingIn = "Knees caving in"
    case backRounding = "Back rounding"
    case limitedRangeOfMotion = "Limited range of motion"
    case unstableTempo = "Unstable tempo"
    case lowConfidence = "Low confidence"
    case unknown = "Unknown"

    var id: String { rawValue }
}

enum AppReadinessItemStatus: String, CaseIterable, Identifiable {
    case ready = "Ready"
    case needsAttention = "Needs Attention"
    case blocked = "Blocked"
    case notChecked = "Not Checked"

    var id: String { rawValue }
}
