//
//  ProfileView.swift
//  to-do-list-apppp
//
//  Halaman profil user — menampilkan info akun dan opsi:
//  • Edit username
//  • Ganti password
//  • Logout
//  • Hapus akun
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

    // Avatar initial letter
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
        // ── Alerts ──
        .alert("Notifikasi", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .confirmationDialog("Logout dari akun ini?", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
            Button("Logout", role: .destructive) {
                authService.signOut()
            }
            Button("Batal", role: .cancel) {}
        }
        .confirmationDialog(
            "Hapus akun secara permanen? Semua data akan hilang dan tidak bisa dikembalikan.",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Hapus Akun", role: .destructive) { handleDeleteAccount() }
            Button("Batal", role: .cancel) {}
        }
        .onAppear {
            usernameInput = authService.displayName ?? ""
        }
    }

    // MARK: - Avatar Card

    private var avatarCard: some View {
        VStack(spacing: 14) {
            // Avatar circle
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

            // Name + email + provider badge
            VStack(spacing: 5) {
                Text(authService.displayName ?? "User")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(theme.cardText)

                if let email = authService.userEmail {
                    Text(email)
                        .font(.system(size: 13))
                        .foregroundColor(theme.secondaryText)
                }

                // Badge: Google atau Email
                if authService.isGoogleUser {
                    Label("Masuk via Google", systemImage: "globe")
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

    // MARK: - Username Card

    private var usernameCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Section label
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(theme.accent)
                Text("Username")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(theme.secondaryText)
            }

            if isEditingUsername {
                // Edit mode
                VStack(spacing: 10) {
                    PTextField(
                        placeholder: "Masukkan username baru",
                        text: $usernameInput,
                        theme: theme
                    )

                    HStack(spacing: 10) {
                        // Cancel
                        Button(action: {
                            usernameInput = authService.displayName ?? ""
                            withAnimation { isEditingUsername = false }
                        }) {
                            Text("Batal")
                                .font(.system(size: 14, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 11)
                                .foregroundColor(theme.accent)
                                .background(theme.accent.opacity(0.12))
                                .cornerRadius(10)
                        }

                        // Save
                        Button(action: handleSaveUsername) {
                            Group {
                                if isSavingUsername {
                                    ProgressView()
                                        .tint(theme.buttonText)
                                } else {
                                    Text("Simpan")
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
                // Display mode
                HStack {
                    Text(authService.displayName ?? "Belum diatur")
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

    // MARK: - Change Password Card

    private var changePasswordCard: some View {
        Group {
            if authService.isGoogleUser {
                // Google user tidak punya password — tampilkan info
                HStack(spacing: 12) {
                    Image(systemName: "lock.slash.fill")
                        .font(.system(size: 18))
                        .foregroundColor(theme.secondaryText)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Ganti Password")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(theme.cardText)
                        Text("Tidak tersedia — kamu login via Google")
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
                // Email/password user — form ganti password
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
                            Text("Ganti Password")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(theme.cardText)
                            Spacer()
                            Image(systemName: showPasswordSection ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(theme.secondaryText)
                        }
                    }
                    .padding(18)

                    if showPasswordSection {
                        Divider()
                            .background(theme.secondaryText.opacity(0.15))
                            .padding(.horizontal, 18)

                        VStack(spacing: 10) {
                            PSecureField(placeholder: "Password saat ini",        text: $currentPassword, theme: theme)
                            PSecureField(placeholder: "Password baru",            text: $newPassword,     theme: theme)
                            PSecureField(placeholder: "Konfirmasi password baru", text: $confirmPassword, theme: theme)

                            if let err = authService.errorMessage, !err.isEmpty {
                                Label(err, systemImage: "exclamationmark.circle.fill")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 2)
                            }

                            Button(action: handleChangePassword) {
                                Group {
                                    if isSavingPassword {
                                        ProgressView().tint(theme.buttonText)
                                    } else {
                                        Text("Update Password")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .foregroundColor(theme.buttonText)
                                .background(theme.accent)
                                .cornerRadius(10)
                            }
                            .disabled(isSavingPassword)
                        }
                        .padding(.horizontal, 18)
                        .padding(.bottom, 18)
                        .padding(.top, 14)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .background(theme.cardBackground)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                .clipped()
            }
        }
    }

    // MARK: - Account Actions Card

    private var accountActionsCard: some View {
        VStack(spacing: 10) {
            // Logout
            Button(action: { showLogoutConfirm = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.right.square.fill")
                        .font(.system(size: 17))
                    Text("Logout")
                        .font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .opacity(0.6)
                }
                .foregroundColor(.orange)
                .padding(.horizontal, 18)
                .padding(.vertical, 15)
                .background(Color.orange.opacity(0.10))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.orange.opacity(0.25), lineWidth: 1)
                )
            }

            // Delete Account
            Button(action: { showDeleteConfirm = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 17))
                    Text("Hapus Akun")
                        .font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .opacity(0.6)
                }
                .foregroundColor(.red)
                .padding(.horizontal, 18)
                .padding(.vertical, 15)
                .background(Color.red.opacity(0.08))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.red.opacity(0.22), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Handlers

    private func handleSaveUsername() {
        let trimmed = usernameInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            alertMessage = "Username tidak boleh kosong."
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
                    alertMessage = authService.errorMessage ?? "Gagal menyimpan username."
                    showAlert = true
                }
            }
        }
    }

    private func handleChangePassword() {
        authService.errorMessage = nil

        guard !currentPassword.isEmpty, !newPassword.isEmpty, !confirmPassword.isEmpty else {
            authService.errorMessage = "Semua field password harus diisi."
            return
        }
        guard newPassword == confirmPassword else {
            authService.errorMessage = "Password baru & konfirmasi tidak cocok."
            return
        }
        guard newPassword.count >= 6 else {
            authService.errorMessage = "Password baru minimal 6 karakter."
            return
        }

        isSavingPassword = true
        Task {
            await authService.changePassword(currentPassword: currentPassword, newPassword: newPassword)
            await MainActor.run {
                isSavingPassword = false
                if authService.errorMessage == nil {
                    // Sukses
                    currentPassword = ""; newPassword = ""; confirmPassword = ""
                    withAnimation { showPasswordSection = false }
                    alertMessage = "Password berhasil diubah! ✅"
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
                    alertMessage = "Gagal hapus akun: \(err)"
                    showAlert = true
                }
                // Jika sukses, authStateListener otomatis set currentUser = nil → kembali ke LoginPage
            }
        }
    }
}

// MARK: - Reusable Input Components

struct PTextField: View {
    let placeholder: String
    @Binding var text: String
    let theme: AppTheme

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 15))
            .foregroundColor(theme.cardText)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(theme.buttonBackground)
            .cornerRadius(10)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
    }
}

struct PSecureField: View {
    let placeholder: String
    @Binding var text: String
    let theme: AppTheme

    var body: some View {
        SecureField(placeholder, text: $text)
            .font(.system(size: 15))
            .foregroundColor(theme.cardText)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(theme.buttonBackground)
            .cornerRadius(10)
    }
}

// MARK: - Preview

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(authService: AuthService(), theme: themes[1])
    }
}
