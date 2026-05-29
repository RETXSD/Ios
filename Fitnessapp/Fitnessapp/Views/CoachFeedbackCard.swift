import SwiftUI

struct CoachFeedbackCard: View {
    let feedback: FormFeedback?
    let errorMessage: String?

    var body: some View {
        FitnessCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Live Feedback", systemImage: "waveform.path.ecg")
                    .font(.headline)
                    .foregroundStyle(FitnessTheme.primary)

                LabeledContent("Exercise", value: feedback?.exerciseName ?? "Waiting")
                    .foregroundStyle(FitnessTheme.text, FitnessTheme.textMuted)

                LabeledContent("Form Score", value: scoreText)
                    .foregroundStyle(FitnessTheme.text, FitnessTheme.textMuted)

                LabeledContent("Confidence", value: confidenceText)
                    .foregroundStyle(FitnessTheme.text, FitnessTheme.textMuted)

                Text(feedback?.message ?? errorMessage ?? "Start the camera and move fully into frame.")
                    .font(.subheadline)
                    .foregroundStyle(feedback == nil && errorMessage != nil ? .red : FitnessTheme.textMuted)

                if let issues = feedback?.detectedIssues, !issues.isEmpty {
                    Text(issues.joined(separator: ", "))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(FitnessTheme.gold)
                }
            }
        }
    }

    private var scoreText: String {
        guard let score = feedback?.score else {
            return "Waiting"
        }

        return "\(Int(score * 100))%"
    }

    private var confidenceText: String {
        guard let confidence = feedback?.confidence else {
            return "Waiting"
        }

        return "\(Int(confidence * 100))%"
    }
}
