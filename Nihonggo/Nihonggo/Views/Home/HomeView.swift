import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @EnvironmentObject private var languageSettings: LanguageSettings
    private let progressService: ProgressService

    init(progressService: ProgressService) {
        self.progressService = progressService
        _viewModel = StateObject(wrappedValue: HomeViewModel(progressService: progressService))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    AppCard {
                        Text(languageSettings.language.text(.welcomeBack))
                            .font(.title)
                            .bold()
                        Text("\(languageSettings.language.text(.continueLevel)) \(viewModel.currentLevel)")
                            .font(.headline)
                        HStack {
                            AppBadge(viewModel.currentLevel, color: AppTheme.toriiRed, systemImage: "flag.fill")
                            AppBadge("\(viewModel.xp) XP", color: AppTheme.kinkakuGold, systemImage: "bolt.fill")
                            AppBadge("\(viewModel.streak) \(languageSettings.language.text(.daySuffix))", color: AppTheme.sakuraBlush, systemImage: "flame.fill")
                        }
                    }

                    AppCard {
                        Text(languageSettings.language.text(.todayRoute))
                            .font(.title3)
                            .bold()
                        ProgressBar(progress: min(Double(viewModel.xp % 500) / 500, 1), label: languageSettings.language.text(.xpToNextLevel))
                    }

                    NavigationLink {
                        LessonGridView(progressService: progressService)
                    } label: {
                        AppCard {
                            Label(languageSettings.language.text(.openLesson), systemImage: "book.closed.fill")
                                .font(.headline)
                                .bold()
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding()
            }
            .navigationTitle(languageSettings.language.text(.homeTitle))
            .appScreenBackground()
        }
    }
}
