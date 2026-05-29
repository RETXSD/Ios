import SwiftUI

struct AuthenticationView: View {
    let onAuthenticated: (AppUser, UserFitnessProfile?) -> Void

    @StateObject private var viewModel = AuthenticationViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    AuthHeaderView()

                    Picker("Authentication mode", selection: $viewModel.authMode) {
                        ForEach(AuthMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .colorScheme(.dark)
                    .tint(FitnessTheme.primary)
                    .disabled(viewModel.isLoading)

                    AuthFormView(
                        authMode: viewModel.authMode,
                        username: $viewModel.username,
                        email: $viewModel.email,
                        password: $viewModel.password
                    )

                    AuthActionButtonsView(
                        authMode: viewModel.authMode,
                        isLoading: viewModel.isLoading,
                        primaryAction: submit,
                        googleAction: continueWithGoogle
                    )
                }
                .padding()
            }
            .background { FitnessTheme.pageBackground }
            .preferredColorScheme(.dark)
            .navigationTitle(viewModel.authMode.rawValue)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(FitnessTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .alert("Authentication failed", isPresented: errorBinding) {
                Button("OK", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "Please try again.")
            }
        }
    }

    private func submit() {
        Task {
            guard let session = await viewModel.submit() else {
                return
            }

            onAuthenticated(session.0, session.1)
        }
    }

    private func continueWithGoogle() {
        Task {
            guard let session = await viewModel.continueWithGoogle() else {
                return
            }

            onAuthenticated(session.0, session.1)
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.errorMessage = nil
                }
            }
        )
    }
}
