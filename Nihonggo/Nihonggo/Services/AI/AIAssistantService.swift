import Foundation

actor AIAssistantService {
    static func systemPrompt(language: AppLanguage) -> String {
        "You are a Japanese language tutor. Answer only in the context of learning Japanese. Always include Japanese characters with romaji when giving examples. \(language.aiInstruction)"
    }

    private let endpoint: URL
    private let session: URLSession

    init(endpoint: URL = URL(string: "http://10.24.203.75:3000/chat") ?? URL(fileURLWithPath: "/chat"), session: URLSession = .shared) {
        self.endpoint = endpoint
        self.session = session
    }

    func send(messages: [ChatMessage], language: AppLanguage) async throws -> ChatMessage {
        let payload = ChatRequest(
            model: "deepseek-v4-flash",
            messages: [ChatPayloadMessage(role: "system", content: Self.systemPrompt(language: language))]
                + messages.map { ChatPayloadMessage(role: $0.role.rawValue, content: $0.content) },
            temperature: 0.4
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                throw AIAssistantError.proxyUnavailable
            }
            let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
            let content = decoded.choices.first?.message.content ?? ""
            guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw AIAssistantError.emptyResponse
            }
            return ChatMessage(role: .assistant, content: content)
        } catch let error as AIAssistantError {
            throw error
        } catch {
            throw AIAssistantError.proxyUnavailable
        }
    }
}

enum AIAssistantError: LocalizedError {
    case proxyUnavailable
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .proxyUnavailable:
            return "Koneksi AI bermasalah. Pastikan proxy server berjalan."
        case .emptyResponse:
            return "AI belum memberi jawaban. Coba lagi."
        }
    }
}

private struct ChatRequest: Encodable {
    let model: String
    let messages: [ChatPayloadMessage]
    let temperature: Double
}

private struct ChatPayloadMessage: Codable {
    let role: String
    let content: String
}

private struct ChatResponse: Decodable {
    let choices: [ChatChoice]
}

private struct ChatChoice: Decodable {
    let message: ChatPayloadMessage
}
