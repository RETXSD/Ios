import Foundation

@MainActor
final class DictionaryViewModel: ObservableObject {
    @Published var query = ""
    @Published private(set) var entries: [DictionaryEntry] = []
    @Published var selectedEntry: DictionaryEntry?

    private let service: DictionaryService

    init(service: DictionaryService = DictionaryService()) {
        self.service = service
    }

    func load() async {
        entries = await service.loadEntries()
    }

    func search() async {
        entries = await service.search(query)
    }

    func select(_ entry: DictionaryEntry) {
        selectedEntry = entry
    }
}
