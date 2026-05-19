import SwiftUI

struct CoachFeedbackCard: View {
    var body: some View {
        FitnessCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Live Feedback", systemImage: "waveform.path.ecg")
                    .font(.headline)
                    .foregroundStyle(FitnessTheme.secondary)

                LabeledContent("Form Score", value: "Waiting")
                    .foregroundStyle(.white, .secondary)

                LabeledContent("Rep Count", value: "0")
                    .foregroundStyle(.white, .secondary)

                Text("Vision body-pose feedback is ready in the manager layer. The camera UI can be connected after privacy strings are configured.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
