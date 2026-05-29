import SwiftUI

struct ExerciseCatalogRow: View {
    let exercise: ExerciseCatalogItem

    var body: some View {
        FitnessCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: iconName)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(FitnessTheme.primary)
                        .frame(width: 34, height: 34)
                        .background(FitnessTheme.violetDeep, in: RoundedRectangle(cornerRadius: FitnessTheme.controlRadius))
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(exercise.name)
                            .font(.headline)
                            .foregroundStyle(FitnessTheme.text)

                        Text("\(exercise.category.rawValue.capitalized) • \(exercise.intensity.rawValue.capitalized) • \(exercise.level.rawValue.capitalized)")
                            .font(.subheadline)
                            .foregroundStyle(FitnessTheme.textMuted)
                    }

                    Spacer()

                    Text("\(Int(exercise.kcalPerMinute)) kcal/min")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(FitnessTheme.ink)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(FitnessTheme.primary, in: Capsule())
                }

                Text(exercise.instructions)
                    .font(.subheadline)
                    .foregroundStyle(FitnessTheme.textMuted)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    MetricPill(exercise.equipment.capitalized, systemImage: "dumbbell")

                    if let firstFocus = exercise.bodyFocus.first {
                        MetricPill(firstFocus.capitalized, systemImage: "scope")
                    }
                }
            }
        }
    }

    private var iconName: String {
        switch exercise.category {
        case .cardio:
            return "figure.run"
        case .strength:
            return "figure.strengthtraining.traditional"
        case .core:
            return "figure.core.training"
        case .fullBody:
            return "flame.fill"
        case .mobility:
            return "figure.flexibility"
        case .recovery:
            return "leaf.fill"
        }
    }
}
