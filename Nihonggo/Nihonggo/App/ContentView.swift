import SwiftUI

struct ContentView: View {
    @StateObject private var progressService = ProgressService()
    @StateObject private var languageSettings = LanguageSettings()
    @State private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                TabView {
                    HomeView(progressService: progressService)
                        .tabItem {
                            Label(languageSettings.language.text(.homeTab), systemImage: "house.fill")
                        }
                    LessonGridView(progressService: progressService)
                        .tabItem {
                            Label(languageSettings.language.text(.lessonsTab), systemImage: "book.closed.fill")
                        }
                    ScanView()
                        .tabItem {
                            Label(languageSettings.language.text(.scanTab), systemImage: "camera.viewfinder")
                        }
                    DictionaryView()
                        .tabItem {
                            Label(languageSettings.language.text(.dictionaryTab), systemImage: "character.book.closed.fill")
                        }
                    MoreView(progressService: progressService)
                        .tabItem {
                            Label(languageSettings.language.text(.moreTab), systemImage: "ellipsis.circle.fill")
                        }
                }
                .environmentObject(progressService)
                .environmentObject(languageSettings)
                .tint(AppTheme.toriiRed)
            } else {
                NavigationStack {
                    OnboardingView {
                        hasCompletedOnboarding = true
                    }
                }
            }
        }
        .environmentObject(languageSettings)
        .appScreenBackground()
    }
}
