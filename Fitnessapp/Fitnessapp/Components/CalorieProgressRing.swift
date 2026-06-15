import SwiftUI

struct CalorieProgressRing: View {
    let progress: CalorieProgress

    var body: some View {
        ZStack {
            Circle()
                .stroke(FitnessTheme.surface, lineWidth: 8)

            Circle()
                .trim(from: 0, to: progress.progressRatio)
                .stroke(
                    FitnessTheme.primary,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: FitnessTheme.glow, radius: 12, x: 0, y: 0)

            VStack(spacing: 2) {
                Text(progress.progressRatio, format: .percent.precision(.fractionLength(0)))
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundStyle(FitnessTheme.text)

                Text("goal")
                    .font(.caption)
                    .foregroundStyle(FitnessTheme.textMuted)
            }
        }
        .frame(width: 112, height: 112)
        .accessibilityLabel("Daily calorie progress")
        .accessibilityValue(Text(progress.progressRatio, format: .percent.precision(.fractionLength(0))))
    }
}
