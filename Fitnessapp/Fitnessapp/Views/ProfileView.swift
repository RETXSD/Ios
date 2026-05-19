import SwiftUI

struct ProfileView: View {
    let summary: FitnessDashboardSummary

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    GoalSummaryCard(progress: summary.progress)
                    ProfileReadinessCard(items: summary.readinessItems)
                }
                .padding()
            }
            .background(FitnessTheme.background)
            .navigationTitle("Profile")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(FitnessTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}
