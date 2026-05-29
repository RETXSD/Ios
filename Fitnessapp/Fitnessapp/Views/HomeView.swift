import SwiftUI

struct HomeView: View {
    let summary: FitnessDashboardSummary
    let isLoading: Bool
    let onOpenAssistant: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TodayHeaderView()
                    HomeCalorieCard(progress: summary.progress, isLoading: isLoading)
                    HomeRecommendationCard(workout: summary.todayRecommendation)
                    AIAssistantCard(action: onOpenAssistant)
                    HomeStatusCard(summary: summary)
                }
                .padding()
            }
            .background { FitnessTheme.pageBackground }
            .navigationTitle("Home")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(FitnessTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}
