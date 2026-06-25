import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    @EnvironmentObject private var progressService: ProgressService
    @EnvironmentObject private var languageSettings: LanguageSettings
    @StateObject private var audioService = AudioService()
    @State private var selectedCardIndex = 0
    @State private var isShowingBack = false

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

                if lesson.cards.indices.contains(selectedCardIndex) {
                    let card = lesson.cards[selectedCardIndex]
                    FlashcardView(card: card, isShowingBack: isShowingBack, audioService: audioService)
                    AppButton(
                        isShowingBack ? languageSettings.language.text(.nextCard) : languageSettings.language.text(.showAnswer),
                        systemImage: isShowingBack ? "arrow.right.circle.fill" : "eye.fill"
                    ) {
                        if isShowingBack {
                            nextCard()
                        } else {
                            isShowingBack = true
                            audioService.speak(card.character)
                        }
                    }
                }

                NavigationLink {
                    ExamView(lesson: lesson, progressService: progressService)
                } label: {
                    AppCard {
                        Label(languageSettings.language.text(.lessonDetailExam), systemImage: "checkmark.seal.fill")
                            .font(.headline)
                            .bold()
                    }
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .navigationTitle(lesson.level)
        .appScreenBackground()
    }

    private func nextCard() {
        guard !lesson.cards.isEmpty else { return }
        selectedCardIndex = min(selectedCardIndex + 1, lesson.cards.count - 1)
        isShowingBack = false
        let completion = Double(selectedCardIndex + 1) / Double(lesson.cards.count)
        progressService.markLessonProgress(level: lesson.level, completion: completion)
    }
}
