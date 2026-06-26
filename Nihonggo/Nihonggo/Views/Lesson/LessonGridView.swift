import SwiftUI

struct LessonGridView: View {
    @StateObject private var viewModel: LessonViewModel
    @EnvironmentObject private var languageSettings: LanguageSettings

    init(progressService: ProgressService) {
        _viewModel = StateObject(wrappedValue: LessonViewModel(progressService: progressService))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.lessons) { lesson in
                        ZStack {
                            NavigationLink(value: lesson) {
                                AppCard {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack {
                                                AppBadge(lesson.level, color: AppTheme.kinkakuGold, systemImage: "flag.fill")
                                                AppBadge(languageSettings.language.text(.fiveInternalLevels), color: AppTheme.sakuraBlush, systemImage: "square.grid.2x2.fill")
                                            }
                                            Text(lesson.title)
                                                .font(.title3)
                                                .bold()
                                            Text(lesson.summary)
                                                .font(.body)
                                            ProgressBar(progress: viewModel.completion(for: lesson), label: languageSettings.language.text(.completeLabel))
                                        }
                                        Spacer()
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .disabled(!viewModel.isUnlocked(lesson))

                            if !viewModel.isUnlocked(lesson) {
                                LockedOverlay(message: lockedMessage(for: lesson.level))
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(languageSettings.language.text(.lessonsTitle))
            .navigationDestination(for: Lesson.self) { lesson in
                LessonDetailView(lesson: lesson)
            }
            .appScreenBackground()
        }
    }

    private func lockedMessage(for level: String) -> String {
        let prerequisite = prerequisiteLevel(for: level)
        return "\(languageSettings.language.text(.lockedLevel)) \(prerequisite)"
    }

    private func prerequisiteLevel(for level: String) -> String {
        switch level {
        case "N4":
            return "N5"
        case "N3":
            return "N4"
        case "N2":
            return "N3"
        case "N1":
            return "N2"
        default:
            return "N5"
        }
    }
}
