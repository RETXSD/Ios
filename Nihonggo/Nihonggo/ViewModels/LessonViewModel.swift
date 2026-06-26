import Combine
import Foundation

@MainActor
final class LessonViewModel: ObservableObject {
    @Published private(set) var lessons: [Lesson] = []
    @Published private(set) var unlockedLevels: [String] = ["N5"]
    @Published var selectedCardIndex = 0
    @Published var isShowingBack = false

    private let progressService: ProgressService
    private var cancellables = Set<AnyCancellable>()

    init(progressService: ProgressService) {
        self.progressService = progressService
        lessons = Self.loadLessons()
        bind()
    }

    func isUnlocked(_ lesson: Lesson) -> Bool {
        unlockedLevels.contains(lesson.level)
    }

    func completion(for lesson: Lesson) -> Double {
        progressService.completion(for: lesson.level)
    }

    func completion(for lesson: Lesson, stage: LessonStage) -> Double {
        progressService.completion(level: lesson.level, stageNumber: stage.number)
    }

    func isStageUnlocked(_ stage: LessonStage, in lesson: Lesson) -> Bool {
        progressService.isStageUnlocked(level: lesson.level, stageNumber: stage.number)
    }

    func resetFlashcards() {
        selectedCardIndex = 0
        isShowingBack = false
    }

    func showBack() {
        isShowingBack = true
    }

    func nextCard(in lesson: Lesson) {
        guard !lesson.cards.isEmpty else { return }
        selectedCardIndex = min(selectedCardIndex + 1, lesson.cards.count - 1)
        isShowingBack = false
        let completion = Double(selectedCardIndex + 1) / Double(lesson.cards.count)
        progressService.markLessonProgress(level: lesson.level, completion: completion)
    }

    private func bind() {
        progressService.$progress
            .map(\.unlockedLevels)
            .assign(to: &$unlockedLevels)
    }

    private static func loadLessons() -> [Lesson] {
        guard let url = Bundle.main.url(forResource: "lessons", withExtension: "json") else {
            return fallbackLessons
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Lesson].self, from: data)
        } catch {
            #if DEBUG
            print("Lesson load failed: \(error.localizedDescription)")
            #endif
            return fallbackLessons
        }
    }

    static let fallbackLessons = [
        Lesson(
            id: "n5",
            level: "N5",
            title: "First Kana",
            summary: "Start with core kana and simple words.",
            cards: [
                FlashCard(id: "a", character: "あ", reading: "a", meaning: "a sound", exampleJP: "あめ", exampleReading: "ame", exampleEN: "rain"),
                FlashCard(id: "ka", character: "か", reading: "ka", meaning: "ka sound", exampleJP: "かさ", exampleReading: "kasa", exampleEN: "umbrella"),
                FlashCard(id: "mizu", character: "水", reading: "mizu", meaning: "water", exampleJP: "水を飲みます", exampleReading: "mizu o nomimasu", exampleEN: "I drink water")
            ]
        ),
        Lesson(id: "n4", level: "N4", title: "Daily Kanji", summary: "Useful signs, actions, and places.", cards: []),
        Lesson(id: "n3", level: "N3", title: "Longer Reading", summary: "Intermediate vocabulary and sentences.", cards: []),
        Lesson(id: "n2", level: "N2", title: "Nuance Builder", summary: "Advanced kanji and context.", cards: []),
        Lesson(id: "n1", level: "N1", title: "Mastery", summary: "High-level literacy practice.", cards: [])
    ]
}
