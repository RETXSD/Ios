import SwiftUI

struct OnboardingHeaderView: View {
    let username: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Set your goals")
                .font(.largeTitle.bold())
                .foregroundStyle(FitnessTheme.text)

            Text("Hi \(username.isEmpty ? "there" : username), add the profile data the app will use for workout recommendations.")
                .font(.body)
                .foregroundStyle(FitnessTheme.textMuted)
        }
        .accessibilityElement(children: .combine)
    }
}
