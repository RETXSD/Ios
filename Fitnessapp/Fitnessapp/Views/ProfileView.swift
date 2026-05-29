import SwiftUI

struct ProfileView: View {
    let summary: FitnessDashboardSummary
    let username: String
    let email: String
    let profile: UserFitnessProfile?
    let isSavingProfile: Bool
    let saveProfileAction: (UserFitnessProfile) -> Void
    let logoutAction: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ProfileAccountCard(username: username, email: email, logoutAction: logoutAction)

                    if let profile {
                        GoalSummaryCard(progress: summary.progress, profile: profile)
                        ProfileEditorCard(
                            profile: profile,
                            isSaving: isSavingProfile,
                            saveAction: saveProfileAction
                        )
                    } else {
                        GoalSummaryCard(progress: summary.progress, profile: nil)
                    }

                    ProfileReadinessCard(items: summary.readinessItems)
                }
                .padding()
            }
            .background { FitnessTheme.pageBackground }
            .navigationTitle("Profile")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(FitnessTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}
