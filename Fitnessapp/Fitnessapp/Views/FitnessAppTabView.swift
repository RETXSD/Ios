import SwiftUI

struct FitnessAppTabView: View {
    @State private var launchStage: AppLaunchStage = .authentication
    @State private var selectedTab: FitnessTab = .home
    @State private var dashboardSummary = FitnessDashboardSummary.preview
    @State private var isLoading = true
    @State private var username = "Fitness User"
    @State private var email = ""
    @State private var currentUser: AppUser?
    @State private var currentProfile: UserFitnessProfile?
    @State private var isSavingProfile = false
    @State private var errorMessage: String?
    @State private var isShowingAIAssistant = false
    @StateObject private var aiAssistantViewModel = AIAssistantViewModel()

    private let dashboardManager = FitnessDashboardManager()

    init() {
        configureNavigationAppearance()
    }

    var body: some View {
        Group {
            switch launchStage {
            case .authentication:
                AuthenticationView(onAuthenticated: handleAuthentication)
            case .onboarding:
                if let currentProfile {
                    OnboardingView(
                        profile: currentProfile,
                        isSaving: isSavingProfile,
                        onComplete: completeOnboarding
                    )
                } else {
                    AuthenticationView(onAuthenticated: handleAuthentication)
                }
            case .main:
                mainTabs
            }
        }
        .task {
            await loadDashboard()
        }
        .sheet(isPresented: $isShowingAIAssistant) {
            AIAssistantView(
                viewModel: aiAssistantViewModel,
                userId: currentUser?.id ?? "local-user",
                profile: currentProfile,
                exercises: ExerciseCatalogService.defaultExercises
            )
        }
        .alert("App message", isPresented: errorBinding) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "Please try again.")
        }
    }

    private var mainTabs: some View {
        TabView(selection: $selectedTab) {
            HomeView(
                summary: dashboardSummary,
                isLoading: isLoading,
                onOpenAssistant: openAIAssistant
            )
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(FitnessTab.home)

            WorkoutsView(progress: dashboardSummary.progress)
                .tabItem {
                    Label("Workouts", systemImage: "figure.strengthtraining.traditional")
                }
                .tag(FitnessTab.workouts)

            CoachView(cameraStatus: dashboardSummary.cameraStatus)
                .tabItem {
                    Label("Coach", systemImage: "camera.viewfinder")
                }
                .tag(FitnessTab.coach)

            ProfileView(
                summary: dashboardSummary,
                username: username,
                email: email,
                profile: currentProfile,
                isSavingProfile: isSavingProfile,
                saveProfileAction: saveProfile,
                logoutAction: logout
            )
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle")
            }
            .tag(FitnessTab.profile)
        }
        .tint(FitnessTheme.primary)
        .background { FitnessTheme.pageBackground }
        .toolbarColorScheme(.dark, for: .tabBar)
        .toolbarBackground(FitnessTheme.tabBackground, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }

    private func handleAuthentication(user: AppUser, profile: UserFitnessProfile?) {
        currentUser = user
        currentProfile = profile ?? defaultProfile(for: user)
        username = currentProfile?.username ?? user.username
        email = currentProfile?.email ?? user.email

        launchStage = currentProfile?.onboardingCompleted == true ? .main : .onboarding
    }

    private func completeOnboarding(profile: UserFitnessProfile) {
        saveProfile(profile, moveToMainAfterSave: true)
    }

    private func saveProfile(_ profile: UserFitnessProfile) {
        saveProfile(profile, moveToMainAfterSave: false)
    }

    private func saveProfile(_ profile: UserFitnessProfile, moveToMainAfterSave: Bool) {
        isSavingProfile = true

        Task {
            currentProfile = profile
            username = profile.username
            email = profile.email
            if moveToMainAfterSave {
                launchStage = .main
            }
            isSavingProfile = false
        }
    }

    private func openAIAssistant() {
        isShowingAIAssistant = true
    }

    private func logout() {
        currentUser = nil
        currentProfile = nil
        username = "Fitness User"
        email = ""
        aiAssistantViewModel.reset()
        selectedTab = .home
        launchStage = .authentication
    }

    private func loadDashboard() async {
        isLoading = true
        dashboardSummary = await dashboardManager.loadSummary()
        isLoading = false
    }

    private func defaultProfile(for user: AppUser) -> UserFitnessProfile {
        UserFitnessProfile(
            userId: user.id,
            username: user.username,
            email: user.email,
            dailyCalorieTarget: 500,
            dailyWorkoutDurationMinutes: 30,
            weightKg: 70,
            age: 20,
            fitnessLevel: .beginner,
            onboardingCompleted: false,
            createdAt: nil,
            updatedAt: nil
        )
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    errorMessage = nil
                }
            }
        )
    }

    private func configureNavigationAppearance() {
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(FitnessTheme.tabBackground)
        tabAppearance.shadowColor = UIColor(FitnessTheme.border)
        configureTabItems(tabAppearance.stackedLayoutAppearance)
        configureTabItems(tabAppearance.inlineLayoutAppearance)
        configureTabItems(tabAppearance.compactInlineLayoutAppearance)

        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithOpaqueBackground()
        navigationAppearance.backgroundColor = UIColor(FitnessTheme.background)
        navigationAppearance.shadowColor = UIColor(FitnessTheme.border)
        navigationAppearance.titleTextAttributes = [.foregroundColor: UIColor(FitnessTheme.text)]
        navigationAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(FitnessTheme.text)]

        UINavigationBar.appearance().standardAppearance = navigationAppearance
        UINavigationBar.appearance().compactAppearance = navigationAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationAppearance
    }

    private func configureTabItems(_ itemAppearance: UITabBarItemAppearance) {
        itemAppearance.selected.iconColor = UIColor(FitnessTheme.primary)
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(FitnessTheme.primary)]
        itemAppearance.normal.iconColor = UIColor(FitnessTheme.textTertiary)
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(FitnessTheme.textTertiary)]
    }
}
