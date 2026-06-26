import SwiftUI

struct ExamView: View {
    let lesson: Lesson
    let stage: LessonStage
    @StateObject private var viewModel: ExamViewModel
    @EnvironmentObject private var languageSettings: LanguageSettings

    init(lesson: Lesson, stage: LessonStage, progressService: ProgressService) {
        self.lesson = lesson
        self.stage = stage
        _viewModel = StateObject(wrappedValue: ExamViewModel(progressService: progressService))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if stage.cards.isEmpty {
                    AppCard {
                        Label(languageSettings.language.text(.examUnavailable), systemImage: "doc.questionmark")
                            .font(.headline)
                    }
                } else if viewModel.answeredCount >= stage.cards.count {
                    AppCard {
                        Text(viewModel.didPass ? languageSettings.language.text(.passed) : languageSettings.language.text(.tryAgain))
                            .font(.title)
                            .bold()
                        Text("\(languageSettings.language.text(.score)) \(viewModel.percentage(total: stage.cards.count))%")
                            .font(.headline)
                        if viewModel.didPass && stage.isExam {
                            AppBadge(languageSettings.language.text(.nextLevelUnlocked), color: AppTheme.kinkakuGold, systemImage: "lock.open.fill")
                        } else if viewModel.didPass {
                            AppBadge("\(languageSettings.language.text(.internalLevel)) \(stage.number) \(languageSettings.language.text(.stageComplete))", color: AppTheme.kinkakuGold, systemImage: "checkmark.seal.fill")
                        }
                        AppButton(languageSettings.language.text(.tryAgain), systemImage: "arrow.clockwise") {
                            viewModel.reset()
                        }
                    }
                } else if let card = viewModel.currentCard(in: stage) {
                    AppCard {
                        AppBadge(questionLabel(for: viewModel.questionKind), color: AppTheme.sakuraBlush, systemImage: questionIcon(for: viewModel.questionKind))
                        CharacterDisplay(character: card.character, reading: card.reading)
                        Text(prompt(for: card, kind: viewModel.questionKind))
                            .font(.headline)

                        if viewModel.questionKind == .flashcardRecall {
                            Text("\(card.exampleJP) • \(card.exampleReading)")
                                .font(.title3)
                                .bold()
                            Text(card.exampleEN)
                                .font(.body)
                        }

                        ForEach(viewModel.options(for: stage, card: card, kind: viewModel.questionKind), id: \.self) { option in
                            AppButton(option, style: .secondary) {
                                viewModel.submit(lesson: lesson, stage: stage, selectedAnswer: option)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(stage.isExam ? "\(languageSettings.language.text(.examTitle)) \(lesson.level)" : "\(lesson.level)-\(stage.number)")
        .appScreenBackground()
        .onAppear {
            if viewModel.answeredCount == 0 {
                viewModel.reset()
            }
        }
    }

    private func questionLabel(for kind: ExamQuestionKind) -> String {
        switch kind {
        case .reading:
            return languageSettings.language.text(.readingQuestion)
        case .meaning:
            return languageSettings.language.text(.matchMeaningQuestion)
        case .blank:
            return languageSettings.language.text(.fillBlankQuestion)
        case .flashcardRecall:
            return languageSettings.language.text(.flashcardQuestion)
        }
    }

    private func questionIcon(for kind: ExamQuestionKind) -> String {
        switch kind {
        case .reading:
            return "textformat.abc"
        case .meaning:
            return "arrow.left.arrow.right"
        case .blank:
            return "square.and.pencil"
        case .flashcardRecall:
            return "rectangle.stack.fill"
        }
    }

    private func prompt(for card: FlashCard, kind: ExamQuestionKind) -> String {
        switch kind {
        case .reading:
            return languageSettings.language.text(.chooseRomaji)
        case .meaning:
            return "\(languageSettings.language.text(.matchMeaningPrompt)) \(card.character)"
        case .blank:
            return "\(viewModel.blankSentence(for: card))"
        case .flashcardRecall:
            return languageSettings.language.text(.flashcardRecallPrompt)
        }
    }
}
