import Foundation

final class AIAssistantService {
    private struct RecommendationRequest: Encodable {
        let profile: UserFitnessProfile
        let exercises: [ExerciseCatalogItem]
        let planPreference: String?
    }

    private struct MessageRequest: Encodable {
        let message: String
        let userId: String
    }

    private let baseURL: URL
    private let urlSession: URLSession

    init(
        baseURL: URL = AIAssistantService.defaultBaseURL,
        urlSession: URLSession = AIAssistantService.defaultURLSession
    ) {
        self.baseURL = baseURL
        self.urlSession = urlSession
    }

    func generateAIRecommendation(
        profile: UserFitnessProfile,
        exercises: [ExerciseCatalogItem],
        planPreference: String?
    ) async throws -> WorkoutRecommendation {
        try await post(
            path: "recommendation",
            payload: RecommendationRequest(
                profile: profile,
                exercises: exercises,
                planPreference: planPreference
            )
        )
    }

    func sendMessage(_ message: String, userId: String) async throws -> AIMessage {
        try await post(
            path: "chat",
            payload: MessageRequest(message: message, userId: userId)
        )
    }

    private func post<Request: Encodable, Response: Decodable>(
        path: String,
        payload: Request
    ) async throws -> Response {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder.aiAssistantEncoder.encode(payload)

        let (data, response) = try await urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw FirebaseServiceError.invalidAIResponse
        }

        return try JSONDecoder.aiAssistantDecoder.decode(Response.self, from: data)
    }

    private static var defaultURLSession: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 180
        configuration.timeoutIntervalForResource = 180
        return URLSession(configuration: configuration)
    }

    private static var defaultBaseURL: URL {
        #if targetEnvironment(simulator)
        return URL(string: "http://127.0.0.1:8787")!
        #else
        return URL(string: "http://10.24.203.75:8787")!
        #endif
    }
}

private extension JSONEncoder {
    static var aiAssistantEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

private extension JSONDecoder {
    static var aiAssistantDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
