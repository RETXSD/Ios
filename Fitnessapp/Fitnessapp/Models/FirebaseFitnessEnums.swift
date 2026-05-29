import Foundation

enum FitnessLevel: String, Codable, CaseIterable, Equatable {
    case beginner
    case intermediate
    case advanced
}

enum ExerciseCategory: String, Codable, CaseIterable, Equatable {
    case cardio
    case strength
    case core
    case fullBody
    case mobility
    case recovery
}

enum ExerciseIntensity: String, Codable, CaseIterable, Equatable {
    case low
    case medium
    case high
}

enum RecommendationSource: String, Codable, CaseIterable, Equatable {
    case ruleBased
    case ai
}

enum AIMessageRole: String, Codable, CaseIterable, Equatable {
    case user
    case assistant
}
