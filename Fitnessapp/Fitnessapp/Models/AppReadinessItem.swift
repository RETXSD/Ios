import Foundation

struct AppReadinessItem: Identifiable, Equatable {
    let id: UUID
    let title: String
    let status: AppReadinessItemStatus
    let detail: String

    init(
        id: UUID = UUID(),
        title: String,
        status: AppReadinessItemStatus,
        detail: String
    ) {
        self.id = id
        self.title = title
        self.status = status
        self.detail = detail
    }
}
