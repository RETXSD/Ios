import XCTest
@testable import Nihonggo

final class AIAssistantServiceTests: XCTestCase {
    func test_aiAssistantService_proxyUnavailable_returnsLocalizedConnectionError() async {
        let service = AIAssistantService(endpoint: URL(fileURLWithPath: "/unreachable"))

        do {
            _ = try await service.send(messages: [ChatMessage(role: .user, content: "Explain あ")])
            XCTFail("Expected proxy error")
        } catch {
            XCTAssertEqual(error.localizedDescription, "Koneksi AI bermasalah. Pastikan proxy server berjalan.")
        }
    }
}
