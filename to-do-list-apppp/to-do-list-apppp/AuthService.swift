import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

final class AuthService: NSObject, ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // Computed helpers
    var displayName: String? { currentUser?.displayName?.isEmpty == false ? currentUser?.displayName : nil }
    var userEmail: String?   { currentUser?.email }

    private var authStateHandle: AuthStateDidChangeListenerHandle?

    override init() {
        super.init()
        currentUser = Auth.auth().currentUser
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
            }
        }
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Sign In (Email/Password)

    func signIn(email: String, password: String) async {
        await MainActor.run { isLoading = true; errorMessage = nil }
        do {
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
        await MainActor.run { isLoading = false }
    }

    // MARK: - Sign Up (Email/Password)

    func signUp(email: String, password: String) async {
        await MainActor.run { isLoading = true; errorMessage = nil }
        do {
            _ = try await Auth.auth().createUser(withEmail: email, password: password)
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
        await MainActor.run { isLoading = false }
    }

    // MARK: - Sign In with Google

    @MainActor
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil

        // Ambil clientID dari Firebase config
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = "Firebase clientID tidak ditemukan."
            isLoading = false
            return
        }

        // Konfigurasi GIDSignIn
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Cari root view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            errorMessage = "Tidak bisa menemukan root view controller."
            isLoading = false
            return
        }

        do {
            // Munculkan Google Sign-In sheet
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
            let user = result.user

            guard let idToken = user.idToken?.tokenString else {
                errorMessage = "Gagal mendapatkan ID token dari Google."
                isLoading = false
                return
            }

            // Buat credential Firebase dari token Google
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            // Sign in ke Firebase
            _ = try await Auth.auth().signIn(with: credential)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Sign Out

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        do {
            try Auth.auth().signOut()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Update Display Name (Username)

    func updateDisplayName(_ name: String) async {
        await MainActor.run { isLoading = true; errorMessage = nil }
        do {
            let request = Auth.auth().currentUser?.createProfileChangeRequest()
            request?.displayName = name
            try await request?.commitChanges()
            await MainActor.run { self.currentUser = Auth.auth().currentUser }
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
        await MainActor.run { isLoading = false }
    }

    // MARK: - Change Password (re-authenticate first)

    func changePassword(currentPassword: String, newPassword: String) async {
        await MainActor.run { isLoading = true; errorMessage = nil }
        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            await MainActor.run {
                errorMessage = "Tidak ada user yang login."
                isLoading = false
            }
            return
        }
        do {
            let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
            try await user.reauthenticate(with: credential)
            try await user.updatePassword(to: newPassword)
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
        await MainActor.run { isLoading = false }
    }

    // MARK: - Delete Account

    func deleteAccount() async {
        await MainActor.run { isLoading = true; errorMessage = nil }
        do {
            try await Auth.auth().currentUser?.delete()
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
        await MainActor.run { isLoading = false }
    }

    // MARK: - Helpers

    /// Cek apakah user login via Google (bukan email/password)
    var isGoogleUser: Bool {
        currentUser?.providerData.contains(where: { $0.providerID == "google.com" }) ?? false
    }
}
