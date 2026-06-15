import SwiftUI

struct AuthActionButtonsView: View {
    let authMode: AuthMode
    let isLoading: Bool
    let primaryAction: () -> Void
    let googleAction: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Button(action: primaryAction) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .tint(FitnessTheme.ink)
                    }

                    Label(authMode.rawValue, systemImage: authMode == .register ? "person.badge.plus.fill" : "arrow.right.circle.fill")
                }
                .font(.headline)
            }
            .buttonStyle(FitnessPrimaryButtonStyle())
            .disabled(isLoading)

            Button(action: googleAction) {
                Label("Continue with Google", systemImage: "g.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(FitnessSecondaryButtonStyle())
            .disabled(isLoading)
        }
    }
}
