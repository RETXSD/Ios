import Foundation

final class ExerciseCatalogService {
    func fetchExercises() async throws -> [ExerciseCatalogItem] {
        Self.defaultExercises
    }

    func seedDefaultExercisesIfNeeded() async throws {
    }

    static let defaultExercises: [ExerciseCatalogItem] = [
        ExerciseCatalogItem(
            id: "running",
            name: "Running",
            category: .cardio,
            intensity: .high,
            kcalPerMinute: 10,
            level: .intermediate,
            equipment: "none",
            instructions: "Run at a steady pace. Keep your posture tall and breathe consistently.",
            bodyFocus: ["legs", "cardio"],
            aiTags: ["fatLoss", "endurance", "outdoor", "highCalorieBurn"],
            isActive: true,
            sortOrder: 10
        ),
        ExerciseCatalogItem(
            id: "walking",
            name: "Walking",
            category: .cardio,
            intensity: .low,
            kcalPerMinute: 4,
            level: .beginner,
            equipment: "none",
            instructions: "Walk at a comfortable pace. Keep shoulders relaxed.",
            bodyFocus: ["legs", "cardio"],
            aiTags: ["beginnerFriendly", "recovery", "lowImpact"],
            isActive: true,
            sortOrder: 20
        ),
        ExerciseCatalogItem(
            id: "squats",
            name: "Squats",
            category: .strength,
            intensity: .medium,
            kcalPerMinute: 6,
            level: .beginner,
            equipment: "none",
            instructions: "Stand with feet shoulder-width apart, lower your hips, then stand back up.",
            bodyFocus: ["legs", "glutes"],
            aiTags: ["beginnerFriendly", "strength", "noEquipment"],
            isActive: true,
            sortOrder: 30
        ),
        ExerciseCatalogItem(
            id: "push-ups",
            name: "Push-ups",
            category: .strength,
            intensity: .medium,
            kcalPerMinute: 7,
            level: .beginner,
            equipment: "none",
            instructions: "Start in a plank position. Lower your chest toward the floor, then push back up while keeping your body straight.",
            bodyFocus: ["chest", "arms", "core"],
            aiTags: ["strength", "upperBody", "noEquipment"],
            isActive: true,
            sortOrder: 40
        ),
        ExerciseCatalogItem(
            id: "jumping-jacks",
            name: "Jumping Jacks",
            category: .cardio,
            intensity: .medium,
            kcalPerMinute: 8,
            level: .beginner,
            equipment: "none",
            instructions: "Jump while spreading your legs and raising your arms overhead, then return to the starting position.",
            bodyFocus: ["fullBody", "cardio"],
            aiTags: ["fatLoss", "cardio", "noEquipment"],
            isActive: true,
            sortOrder: 50
        ),
        ExerciseCatalogItem(
            id: "plank",
            name: "Plank",
            category: .core,
            intensity: .medium,
            kcalPerMinute: 4,
            level: .beginner,
            equipment: "none",
            instructions: "Hold your body in a straight line on your forearms and toes. Keep your core tight and avoid dropping your hips.",
            bodyFocus: ["core"],
            aiTags: ["core", "stability", "noEquipment"],
            isActive: true,
            sortOrder: 60
        ),
        ExerciseCatalogItem(
            id: "lunges",
            name: "Lunges",
            category: .strength,
            intensity: .medium,
            kcalPerMinute: 6,
            level: .beginner,
            equipment: "none",
            instructions: "Step one leg forward, lower your body until both knees are bent, then push back to standing position.",
            bodyFocus: ["legs", "glutes"],
            aiTags: ["strength", "balance", "noEquipment"],
            isActive: true,
            sortOrder: 70
        ),
        ExerciseCatalogItem(
            id: "burpees",
            name: "Burpees",
            category: .fullBody,
            intensity: .high,
            kcalPerMinute: 10,
            level: .intermediate,
            equipment: "none",
            instructions: "Start standing, drop into a squat, kick your feet back into plank, return to squat, then jump up.",
            bodyFocus: ["fullBody", "cardio"],
            aiTags: ["fatLoss", "highCalorieBurn", "conditioning"],
            isActive: true,
            sortOrder: 80
        ),
        ExerciseCatalogItem(
            id: "mountain-climbers",
            name: "Mountain Climbers",
            category: .cardio,
            intensity: .high,
            kcalPerMinute: 9,
            level: .intermediate,
            equipment: "none",
            instructions: "Start in a plank position and quickly drive your knees toward your chest one at a time.",
            bodyFocus: ["core", "cardio"],
            aiTags: ["fatLoss", "core", "conditioning"],
            isActive: true,
            sortOrder: 90
        ),
        ExerciseCatalogItem(
            id: "sit-ups",
            name: "Sit-ups",
            category: .core,
            intensity: .medium,
            kcalPerMinute: 5,
            level: .beginner,
            equipment: "none",
            instructions: "Lie on your back with knees bent, lift your upper body toward your knees, then lower yourself back down.",
            bodyFocus: ["core"],
            aiTags: ["core", "beginnerFriendly", "noEquipment"],
            isActive: true,
            sortOrder: 100
        )
    ]
}
