import SwiftUI

struct LoginPage: View {
    @ObservedObject var authService: AuthService
    @State private var theme: AppTheme = themes[1] // Default Dark theme

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSignUpMode: Bool = false

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Logo / Title ──
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [theme.accent, theme.accent.opacity(0.4)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 72, height: 72)
                                .shadow(color: theme.accent.opacity(0.4), radius: 14, x: 0, y: 6)
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 34))
                                .foregroundColor(.white)
                        }
                        Text("Task Manager")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(theme.cardText)
                        Text(isSignUpMode ? "Sign up to continue" : "Log in to manage your tasks")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(theme.secondaryText)
                    }
                    .padding(.top, 48)
                    .padding(.bottom, 32)

                    // ── Google Sign-In Button ──
                    Button(action: {
                        Task { await authService.signInWithGoogle() }
                    }) {
                        HStack(spacing: 12) {
                            // Google "G" logo
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 28, height: 28)
                                Text("G")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(red: 0.26, green: 0.52, blue: 0.96))
                            }
                            Text("Continue with Google")
                                .font(.system(size: 15, weight: .semibold))
                            Spacer()
                            if authService.isLoading {
                                ProgressView()
                                    .tint(theme.cardText)
                                    .scaleEffect(0.8)
                            }
                        }
                        .foregroundColor(theme.cardText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(theme.cardBackground)
                                .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(theme.secondaryText.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .disabled(authService.isLoading)
                    .padding(.horizontal, 20)

                    // ── Divider ──
                    HStack(spacing: 12) {
                        Rectangle()
                            .fill(theme.secondaryText.opacity(0.2))
                            .frame(height: 1)
                        Text("atau")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(theme.secondaryText)
                        Rectangle()
                            .fill(theme.secondaryText.opacity(0.2))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)

                    // ── Email / Password Fields ──
                    VStack(spacing: 16) {
                        // Email
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Email Addrees", systemImage: "envelope.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(theme.secondaryText)

                            TextField("user@example.com", text: $email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding(14)
                                .background(theme.cardBackground)
                                .cornerRadius(10)
                                .foregroundColor(theme.cardText)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(theme.accent.opacity(0.3), lineWidth: 1)
                                )
                        }

                        // Password
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Password", systemImage: "lock.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(theme.secondaryText)

                            SecureField("Input password", text: $password)
                                .padding(14)
                                .background(theme.cardBackground)
                                .cornerRadius(10)
                                .foregroundColor(theme.cardText)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(theme.accent.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                    .padding(20)
                    .background(theme.cardBackground.opacity(0.5))
                    .cornerRadius(14)
                    .padding(.horizontal, 20)

                    // ── Error Message ──
                    if let errorMessage = authService.errorMessage, !errorMessage.isEmpty {
                        Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.3))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color(red: 1.0, green: 0.3, blue: 0.3).opacity(0.1))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                            .padding(.top, 14)
                    }

                    // ── Submit Button ──
                    Button(action: submit) {
                        HStack {
                            if authService.isLoading {
                                ProgressView().tint(theme.buttonText)
                            }
                            Text(isSignUpMode ? "Sign In" : "Login")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(theme.accent)
                        .foregroundColor(theme.buttonText)
                        .cornerRadius(10)
                    }
                    .disabled(authService.isLoading)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    // ── Toggle Mode ──
                    Button(action: {
                        authService.errorMessage = nil
                        isSignUpMode.toggle()
                    }) {
                        Text(isSignUpMode ? "Alredy have an account" : "Not have an account? Sign In")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(theme.accent)
                    }
                    .disabled(authService.isLoading)
                    .padding(.top, 14)
                    .padding(.bottom, 40)
                }
            }
        }
    }

    private func submit() {
        let trimmedEmail    = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty, !trimmedPassword.isEmpty else {
            authService.errorMessage = "Please input email and password."
            return
        }

        Task {
            if isSignUpMode {
                await authService.signUp(email: trimmedEmail, password: trimmedPassword)
            } else {
                await authService.signIn(email: trimmedEmail, password: trimmedPassword)
            }
        }
    }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage(authService: AuthService())
    }
}
