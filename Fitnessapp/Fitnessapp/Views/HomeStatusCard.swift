import SwiftUI

struct HomeStatusCard: View {
    let summary: FitnessDashboardSummary

    var body: some View {
        FitnessCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Status", systemImage: "checkmark.shield.fill")
                    .font(.headline)
                    .foregroundStyle(FitnessTheme.primary)

                LabeledContent("Apple Health", value: summary.healthKitStatus.rawValue)
                    .foregroundStyle(FitnessTheme.text, FitnessTheme.textMuted)

                LabeledContent("Camera", value: summary.cameraStatus.rawValue)
                    .foregroundStyle(FitnessTheme.text, FitnessTheme.textMuted)
            }
        }
    }
}
