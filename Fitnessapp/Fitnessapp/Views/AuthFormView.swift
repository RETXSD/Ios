import SwiftUI

struct AuthFormView: View {
    let authMode: AuthMode
    @Binding var username: String
    @Binding var email: String
    @Binding var password: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(authMode == .register ? "Create account" : "Welcome back")
                .font(.headline)
                .foregroundStyle(FitnessTheme.text)

            VStack(alignment: .leading, spacing: 12) {
                if authMode == .register {
                    AuthInputField(
                        title: "Username",
                        systemImage: "person.fill",
                        text: $username,
                        textContentType: .username,
                        capitalization: .words
                    )
                }

                AuthInputField(
                    title: "Email",
                    systemImage: "envelope.fill",
                    text: $email,
                    textContentType: .emailAddress,
                    keyboardType: .emailAddress,
                    capitalization: .never
                )

                AuthInputField(
                    title: "Password",
                    systemImage: "lock.fill",
                    text: $password,
                    isSecure: true,
                    textContentType: nil,
                    capitalization: .never
                )
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(FitnessTheme.surfaceRaised, in: RoundedRectangle(cornerRadius: FitnessTheme.cardRadius))
        .overlay {
            RoundedRectangle(cornerRadius: FitnessTheme.cardRadius)
                .stroke(FitnessTheme.border, lineWidth: 1)
        }
    }
}
