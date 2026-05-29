import Foundation

struct ExerciseCatalogItem: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var category: ExerciseCategory
    var intensity: ExerciseIntensity
    var kcalPerMinute: Double
    var level: FitnessLevel
    var equipment: String
    var instructions: String
    var bodyFocus: [String]
    var aiTags: [String]
    var isActive: Bool
    var sortOrder: Int
}
