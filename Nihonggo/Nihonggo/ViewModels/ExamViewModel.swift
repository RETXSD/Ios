import Foundation

enum ExamQuestionKind: CaseIterable {
    case reading
    case meaning
    case blank
    case flashcardRecall
}

@MainActor
final class ExamViewModel: ObservableObject {
    @Published private(set) var score = 0
    @Published private(set) var answeredCount = 0
    @Published private(set) var didPass = false

    private let progressService: ProgressService

    init(progressService: ProgressService) {
        self.progressService = progressService
    }

    func submit(lesson: Lesson, stage: LessonStage, selectedAnswer: String) {
        guard stage.cards.indices.contains(answeredCount) else { return }
        let card = stage.cards[answeredCount]
        if selectedAnswer == expectedAnswer(for: card, kind: questionKind) {
            score += 1
        }
        answeredCount += 1

        if answeredCount == stage.cards.count {
            let percent = percentage(total: stage.cards.count)
            didPass = percent >= 70
            if stage.isExam && didPass {
                progressService.markStageProgress(level: lesson.level, stageNumber: stage.number, completion: 1)
                progressService.recordExam(level: lesson.level, score: percent)
            } else if didPass {
                progressService.markStageProgress(level: lesson.level, stageNumber: stage.number, completion: 1)
            }
        }
    }

    func percentage(total: Int) -> Int {
        guard total > 0 else { return 0 }
        return Int((Double(score) / Double(total) * 100).rounded())
    }

    func reset() {
        score = 0
        answeredCount = 0
        didPass = false
    }

    var questionKind: ExamQuestionKind {
        ExamQuestionKind.allCases[answeredCount % ExamQuestionKind.allCases.count]
    }

    func currentCard(in stage: LessonStage) -> FlashCard? {
        guard stage.cards.indices.contains(answeredCount) else { return nil }
        return stage.cards[answeredCount]
    }

    func expectedAnswer(for card: FlashCard, kind: ExamQuestionKind) -> String {
        switch kind {
        case .reading:
            return card.reading
        case .meaning, .flashcardRecall:
            return card.meaning
        case .blank:
            return card.character
        }
    }

    func blankSentence(for card: FlashCard) -> String {
        if card.exampleJP.contains(card.character) {
            return card.exampleJP.replacingOccurrences(of: card.character, with: "___")
        }
        return "___  \(card.exampleJP)"
    }

    func options(for stage: LessonStage, card: FlashCard, kind: ExamQuestionKind) -> [String] {
        let correct = expectedAnswer(for: card, kind: kind)
        let distractors: [String]

        switch kind {
        case .reading:
            distractors = stage.cards.map(\.reading) + ["ka", "te", "mizu", "gakkou", "sensei"]
        case .meaning, .flashcardRecall:
            distractors = stage.cards.map(\.meaning) + ["station", "teacher", "to study", "beautiful", "important"]
        case .blank:
            distractors = stage.cards.map(\.character) + ["日", "人", "語", "水", "学"]
        }

        return Array(Set([correct] + distractors.filter { $0 != correct }))
            .shuffled()
            .prefix(4)
            .shuffled()
    }
}
