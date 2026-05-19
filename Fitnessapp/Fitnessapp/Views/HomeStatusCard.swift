import SwiftUI

struct HomeStatusCard: View {
    let summary: FitnessDashboardSummary

    var body: some View {
        FitnessCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Status", systemImage: "checkmark.shield.fill")
                    .font(.headline)
                    .foregroundStyle(FitnessTheme.gold)

                LabeledContent("Apple Health", value: summary.healthKitStatus.rawValue)
                    .foregroundStyle(.white, FitnessTheme.secondary)

                LabeledContent("Camera", value: summary.cameraStatus.rawValue)
                    .foregroundStyle(.white, FitnessTheme.secondary)
            }
        }
    }
}
