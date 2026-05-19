import SwiftUI

struct CalorieProgressRing: View {
    let progress: CalorieProgress

    var body: some View {
        ZStack {
            Circle()
                .stroke(.secondary.opacity(0.2), lineWidth: 16)

            Circle()
                .trim(from: 0, to: progress.progressRatio)
                .stroke(
                    LinearGradient(
                        colors: [FitnessTheme.primary, FitnessTheme.secondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                Text(progress.progressRatio, format: .percent.precision(.fractionLength(0)))
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text("goal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 112, height: 112)
        .accessibilityLabel("Daily calorie progress")
        .accessibilityValue(Text(progress.progressRatio, format: .percent.precision(.fractionLength(0))))
    }
}
