import SwiftUI

struct CoachSessionSummaryCard: View {
    let summaries: [CoachExerciseSessionSummary]

    private var totalReps: Int {
        summaries.reduce(0) { $0 + $1.repCount }
    }

    private var totalCalories: Double {
        summaries.reduce(0) { $0 + $1.estimatedCalories }
    }

    private var totalDuration: TimeInterval {
        summaries.reduce(0) { $0 + $1.durationSeconds }
    }

    var body: some View {
        FitnessCard {
            VStack(alignment: .leading, spacing: 14) {
                Label("Workout Summary", systemImage: "list.bullet.clipboard.fill")
                    .font(.headline)
                    .foregroundStyle(FitnessTheme.primary)

                HStack(spacing: 10) {
                    summaryMetric(title: "Total Reps", value: "\(totalReps)")
                    summaryMetric(title: "Calories", value: "\(Int(totalCalories.rounded()))")
                    summaryMetric(title: "Time", value: durationText(totalDuration))
                }

                if summaries.isEmpty {
                    Text("Start the camera and complete reps to build your session summary.")
                        .font(.subheadline)
                        .foregroundStyle(FitnessTheme.textMuted)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    VStack(spacing: 10) {
                        ForEach(summaries) { item in
                            HStack(alignment: .top, spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.exerciseName)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(FitnessTheme.text)

                                    Text("\(item.repCount) reps • \(durationText(item.durationSeconds))")
                                        .font(.caption)
                                        .foregroundStyle(FitnessTheme.textMuted)
                                }

                                Spacer()

                                Text("\(Int(item.estimatedCalories.rounded())) kcal")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(FitnessTheme.ink)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 5)
                                    .background(FitnessTheme.primary, in: Capsule())
                            }
                            .padding(12)
                            .background(FitnessTheme.surface, in: RoundedRectangle(cornerRadius: FitnessTheme.controlRadius))
                            .overlay {
                                RoundedRectangle(cornerRadius: FitnessTheme.controlRadius)
                                    .stroke(FitnessTheme.border, lineWidth: 1)
                            }
                        }
                    }
                }
            }
        }
    }

    private func summaryMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(FitnessTheme.textMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(value)
                .font(.headline.bold())
                .foregroundStyle(FitnessTheme.text)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(FitnessTheme.violetDeep, in: RoundedRectangle(cornerRadius: FitnessTheme.controlRadius))
    }

    private func durationText(_ duration: TimeInterval) -> String {
        let totalSeconds = max(Int(duration.rounded()), 0)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        if minutes == 0 {
            return "\(seconds)s"
        }

        return "\(minutes)m \(seconds)s"
    }
}
