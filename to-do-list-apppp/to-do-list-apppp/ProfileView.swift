//
//  ProfileView.swift
//  to-do-list-apppp
//
//  User profile page — displays account info and options:
//  • Edit username
//  • Change password
//  • Logout
//  • Delete account
//

import SwiftUI

// MARK: - Profile View

struct ProfileView: View {

    @ObservedObject var authService: AuthService
    let theme: AppTheme

    // --- Input fields ---
    @State private var usernameInput: String = ""
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""

    // --- UI state ---
    @State private var isEditingUsername: Bool = false
    @State private var showPasswordSection: Bool = false
    @State private var showLogoutConfirm: Bool = false
    @State private var showDeleteConfirm: Bool = false
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var isSavingUsername: Bool = false
    @State private var isSavingPassword: Bool = false

    private var avatarLetter: String {
        let name = authService.displayName ?? authService.userEmail ?? "?"
        return String(name.prefix(1)).uppercased()
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    avatarCard
                    usernameCard
                    changePasswordCard
                    accountActionsCard

                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .alert("Notification", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .confirmationDialog("Log out of this account?", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
            Button("Logout", role: .destructive) {
                authService.signOut()
            }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog(
            "Delete account permanently? All data will be lost and cannot be recovered.",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete Account", role: .destructive) { handleDeleteAccount() }
            Button("Cancel", role: .cancel) {}
        }
        .onAppear {
            usernameInput = authService.displayName ?? ""
        }
    }

    private var avatarCard: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [theme.accent, theme.accent.opacity(0.45)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)
                    .shadow(color: theme.accent.opacity(0.45), radius: 14, x: 0, y: 6)

                Text(avatarLetter)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            VStack(spacing: 5) {
                Text(authService.displayName ?? "User")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(theme.cardText)

                if let email = authService.userEmail {
                    Text(email)
                        .font(.system(size: 13))
                        .foregroundColor(theme.secondaryText)
                }

                if authService.isGoogleUser {
                    Label("Signed in via Google", systemImage: "globe")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(red: 0.26, green: 0.52, blue: 0.96))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(red: 0.26, green: 0.52, blue: 0.96).opacity(0.12))
                        .cornerRadius(8)
                        .padding(.top, 2)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(theme.cardBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.07), radius: 8, x: 0, y: 4)
    }

    private var usernameCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(theme.accent)
                Text("Username")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(theme.secondaryText)
            }

            if isEditingUsername {
                VStack(spacing: 10) {
                    TextField("Enter new username", text: $usernameInput)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 11)
                        .background(theme.buttonBackground)
                        .cornerRadius(10)
                        .foregroundColor(theme.cardText)

                    HStack(spacing: 10) {
                        Button(action: {
                            usernameInput = authService.displayName ?? ""
                            withAnimation { isEditingUsername = false }
                        }) {
                            Text("Cancel")
                                .font(.system(size: 14, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 11)
                                .foregroundColor(theme.accent)
                                .background(theme.accent.opacity(0.12))
                                .cornerRadius(10)
                        }

                        Button(action: handleSaveUsername) {
                            Group {
                                if isSavingUsername {
                                    ProgressView()
                                        .tint(theme.buttonText)
                                } else {
                                    Text("Save")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .foregroundColor(theme.buttonText)
                            .background(theme.accent)
                            .cornerRadius(10)
                        }
                        .disabled(isSavingUsername)
                    }
                }
            } else {
                HStack {
                    Text(authService.displayName ?? "Not set")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(
                            authService.displayName == nil
                                ? theme.secondaryText.opacity(0.5)
                                : theme.cardText
                        )
                    Spacer()
                    Button(action: { withAnimation(.spring(response: 0.3)) { isEditingUsername = true } }) {
                        Label("Edit", systemImage: "pencil")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(theme.accent)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(theme.accent.opacity(0.13))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(18)
        .background(theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        .animation(.spring(response: 0.35), value: isEditingUsername)
    }

    private var accountActionsCard: some View {
        VStack(spacing: 12) {
            Button(action: { showLogoutConfirm = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "arrowshape.turn.up.left.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                    Text("Logout")
                        .font(.system(size: 15, weight: .semibold))
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                .background(Color(red: 0.25, green: 0.52, blue: 1.0))
                .cornerRadius(12)
                .foregroundColor(.white)
            }

            Button(action: { showDeleteConfirm = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                    Text("Delete Account")
                        .font(.system(size: 15, weight: .semibold))
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                .background(Color(red: 0.85, green: 0.2, blue: 0.2))
                .cornerRadius(12)
                .foregroundColor(.white)
            }
        }
        .padding(18)
        .background(theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
    }

    private var changePasswordCard: some View {
        Group {
            if authService.isGoogleUser {
                HStack(spacing: 12) {
                    Image(systemName: "lock.slash.fill")
                        .font(.system(size: 18))
                        .foregroundColor(theme.secondaryText)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Change Password")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(theme.cardText)
                        Text("Unavailable — you signed in via Google")
                            .font(.system(size: 12))
                            .foregroundColor(theme.secondaryText)
                    }
                    Spacer()
                }
                .padding(18)
                .background(theme.cardBackground)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: {
                        withAnimation(.spring(response: 0.35)) {
                            showPasswordSection.toggle()
                            if !showPasswordSection {
                                currentPassword = ""; newPassword = ""; confirmPassword = ""
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(theme.accent)
                                .frame(width: 18)
                            Text("Change Password")
                            Spacer()
                        }
                    }
                    .padding(18)
                }
            }
        }
    }

    private func handleSaveUsername() {
        let trimmed = usernameInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            alertMessage = "Username cannot be empty."
            showAlert = true
            return
        }
        isSavingUsername = true
        Task {
            await authService.updateDisplayName(trimmed)
            await MainActor.run {
                isSavingUsername = false
                if authService.errorMessage == nil {
                    withAnimation { isEditingUsername = false }
                } else {
                    alertMessage = authService.errorMessage ?? "Failed to save username."
                    showAlert = true
                }
            }
        }
    }

    private func handleChangePassword() {
        authService.errorMessage = nil

        guard !currentPassword.isEmpty, !newPassword.isEmpty, !confirmPassword.isEmpty else {
            authService.errorMessage = "All password fields must be filled."
            return
        }
        guard newPassword == confirmPassword else {
            authService.errorMessage = "New password and confirmation do not match."
            return
        }
        guard newPassword.count >= 6 else {
            authService.errorMessage = "New password must be at least 6 characters."
            return
        }

        isSavingPassword = true
        Task {
            await authService.changePassword(currentPassword: currentPassword, newPassword: newPassword)
            await MainActor.run {
                isSavingPassword = false
                if authService.errorMessage == nil {
                    currentPassword = ""; newPassword = ""; confirmPassword = ""
                    withAnimation { showPasswordSection = false }
                    alertMessage = "Password updated successfully! ✅"
                    showAlert = true
                }
            }
        }
    }

    private func handleDeleteAccount() {
        Task {
            await authService.deleteAccount()
            await MainActor.run {
                if let err = authService.errorMessage {
                    alertMessage = "Failed to delete account: \(err)"
                    showAlert = true
                }
            }
        }
    }
}