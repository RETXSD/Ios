import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    @EnvironmentObject private var progressService: ProgressService
    @EnvironmentObject private var languageSettings: LanguageSettings

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                AppCard {
                    AppBadge(lesson.level, color: AppTheme.kinkakuGold, systemImage: "flag.fill")
                    Text(lesson.title)
                        .font(.title)
                        .bold()
                    Text(lesson.summary)
                }

                ForEach(lesson.stages) { stage in
                    ZStack {
                        NavigationLink {
                            ExamView(lesson: lesson, stage: stage, progressService: progressService)
                        } label: {
                            AppCard {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack {
                                            AppBadge(stageLabel(for: stage), color: stage.isExam ? AppTheme.toriiRed : AppTheme.kinkakuGold, systemImage: stage.isExam ? "checkmark.seal.fill" : "square.grid.2x2.fill")
                                            AppBadge("\(stage.cards.count) \(languageSettings.language.text(.questionCount))", color: AppTheme.sakuraBlush, systemImage: "list.bullet.clipboard")
                                        }

                                        Text(stage.title)
                                            .font(.title3)
                                            .bold()
                                        Text(stage.summary)
                                            .font(.body)
                                        ProgressBar(
                                            progress: progressService.completion(level: lesson.level, stageNumber: stage.number),
                                            label: languageSettings.language.text(.completeLabel)
                                        )
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.headline)
                                        .foregroundStyle(AppTheme.sumiInk)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .disabled(!progressService.isStageUnlocked(level: lesson.level, stageNumber: stage.number))

                        if !progressService.isStageUnlocked(level: lesson.level, stageNumber: stage.number) {
                            LockedOverlay(message: lockedStageMessage(for: stage.number - 1))
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(lesson.level)
        .appScreenBackground()
    }

    private func stageLabel(for stage: LessonStage) -> String {
        stage.isExam ? languageSettings.language.text(.finalExamStage) : "\(languageSettings.language.text(.internalLevel)) \(stage.number)"
    }

    private func lockedStageMessage(for stageNumber: Int) -> String {
        "\(languageSettings.language.text(.lockedStagePrefix)) \(stageNumber) \(languageSettings.language.text(.lockedStageSuffix))"
    }
}
