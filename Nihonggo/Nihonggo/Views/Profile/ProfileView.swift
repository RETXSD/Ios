import SwiftUI

struct ProfileView: View {
    @ObservedObject var progressService: ProgressService
    @EnvironmentObject private var languageSettings: LanguageSettings

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    AppCard {
                        Text(languageSettings.language.text(.profileTitle))
                            .font(.title)
                            .bold()
                        HStack {
                            AppBadge(progressService.currentLevel(), color: AppTheme.toriiRed, systemImage: "person.fill")
                            AppBadge("\(progressService.progress.xp) XP", color: AppTheme.kinkakuGold, systemImage: "bolt.fill")
                            AppBadge("\(progressService.progress.streak) streak", color: AppTheme.sakuraBlush, systemImage: "flame.fill")
                        }
                    }

                    AppCard {
                        ProgressBar(progress: min(Double(progressService.progress.xp % 500) / 500, 1), label: languageSettings.language.text(.xpProgress))
                    }

                    ForEach(["N5", "N4", "N3", "N2", "N1"], id: \.self) { level in
                        AppCard {
                            HStack {
                                AppBadge(level, color: progressService.progress.isUnlocked(level) ? AppTheme.kinkakuGold : AppTheme.sakuraBlush)
                                ProgressBar(progress: progressService.completion(for: level), label: languageSettings.language.text(.completion))
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(languageSettings.language.text(.profileTitle))
            .appScreenBackground()
        }
    }
}
