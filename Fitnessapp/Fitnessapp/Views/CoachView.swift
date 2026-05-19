import SwiftUI

struct CoachView: View {
    let cameraStatus: PermissionStatus

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    CoachPreviewCard(cameraStatus: cameraStatus)
                    CoachFeedbackCard()
                }
                .padding()
            }
            .background(FitnessTheme.background)
            .navigationTitle("Coach")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(FitnessTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}
