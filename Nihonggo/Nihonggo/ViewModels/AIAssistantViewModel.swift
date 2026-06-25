import Foundation

@MainActor
final class AIAssistantViewModel: ObservableObject {
    @Published var draft = ""
    @Published private(set) var messages: [ChatMessage] = []
    @Published private(set) var isSending = false
    @Published private(set) var errorMessage: String?

    private let service: AIAssistantService

    init(service: AIAssistantService = AIAssistantService()) {
        self.service = service
    }

    func updateGreeting(language: AppLanguage) {
        let greeting = language.text(.aiGreeting)
        if messages.isEmpty {
            messages = [ChatMessage(role: .assistant, content: greeting)]
        } else if messages.count == 1, messages.first?.role == .assistant {
            messages = [ChatMessage(role: .assistant, content: greeting)]
        }
    }

    func send(language: AppLanguage) async {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)
        draft = ""
        isSending = true
        errorMessage = nil

        do {
            let reply = try await service.send(messages: messages.filter { $0.role != .system }, language: language)
            messages.append(reply)
        } catch AIAssistantError.proxyUnavailable {
            errorMessage = language.text(.aiProxyError)
        } catch AIAssistantError.emptyResponse {
            errorMessage = language.text(.aiEmptyError)
        } catch {
            errorMessage = language.text(.aiProxyError)
        }

        isSending = false
    }
}
