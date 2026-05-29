import SwiftUI

struct ProfileAccountCard: View {
    let username: String
    let email: String
    let logoutAction: () -> Void

    var body: some View {
        FitnessCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Account", systemImage: "person.crop.circle.fill")
                    .font(.headline)
                    .foregroundStyle(FitnessTheme.primary)

                LabeledContent("Username", value: username)
                    .foregroundStyle(FitnessTheme.text, FitnessTheme.textMuted)

                LabeledContent("Email", value: email.isEmpty ? "Not set" : email)
                    .foregroundStyle(FitnessTheme.text, FitnessTheme.textMuted)

                Button(action: logoutAction) {
                    Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .frame(minHeight: 44)
            }
        }
    }
}
