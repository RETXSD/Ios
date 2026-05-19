import SwiftUI

struct FitnessAppTabView: View {
    @State private var selectedTab: FitnessTab = .home
    @State private var dashboardSummary = FitnessDashboardSummary.preview
    @State private var isLoading = true

    private let dashboardManager = FitnessDashboardManager()

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(summary: dashboardSummary, isLoading: isLoading)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(FitnessTab.home)

            WorkoutsView(progress: dashboardSummary.progress)
                .tabItem {
                    Label("Workouts", systemImage: "figure.strengthtraining.traditional")
                }
                .tag(FitnessTab.workouts)

            CoachView(cameraStatus: dashboardSummary.cameraStatus)
                .tabItem {
                    Label("Coach", systemImage: "camera.viewfinder")
                }
                .tag(FitnessTab.coach)

            ProfileView(summary: dashboardSummary)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(FitnessTab.profile)
        }
        .tint(FitnessTheme.secondary)
        .task {
            await loadDashboard()
        }
    }

    private func loadDashboard() async {
        isLoading = true
        dashboardSummary = await dashboardManager.loadSummary()
        isLoading = false
    }
}
