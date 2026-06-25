import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var currentLevel = "N5"
    @Published private(set) var xp = 0
    @Published private(set) var streak = 1

    private let progressService: ProgressService
    private var cancellables = Set<AnyCancellable>()

    init(progressService: ProgressService) {
        self.progressService = progressService
        bind()
    }

    private func bind() {
        progressService.$progress
            .sink { [weak self] progress in
                self?.currentLevel = self?.progressService.currentLevel() ?? "N5"
                self?.xp = progress.xp
                self?.streak = progress.streak
            }
            .store(in: &cancellables)
    }
}
