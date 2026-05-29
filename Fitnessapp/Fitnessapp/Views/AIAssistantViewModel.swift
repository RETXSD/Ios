import Foundation

@MainActor
final class AIAssistantViewModel: ObservableObject {
    @Published var prompt = ""
    @Published var planPreference = ""
    @Published var messages: [AIMessage] = []
    @Published var recommendation: WorkoutRecommendation?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: AIAssistantService

    init(service: AIAssistantService = AIAssistantService()) {
        self.service = service
    }

    func sendMessage(userId: String) async {
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPrompt.isEmpty, !isLoading else {
            return
        }

        let userMessage = AIMessage(
            id: UUID().uuidString,
            userId: userId,
            role: .user,
            content: trimmedPrompt,
            createdAt: Date.now
        )

        messages.append(userMessage)
        prompt = ""
        isLoading = true
        errorMessage = nil

        do {
            let response = try await service.sendMessage(trimmedPrompt, userId: userId)
            messages.append(response)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func generateRecommendation(
        profile: UserFitnessProfile?,
        exercises: [ExerciseCatalogItem]
    ) async {
        guard let profile, !isLoading else {
            errorMessage = "Complete your profile before asking AI for a workout plan."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            recommendation = try await service.generateAIRecommendation(
                profile: profile,
                exercises: exercises,
                planPreference: trimmedPlanPreference
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func reset() {
        prompt = ""
        planPreference = ""
        messages = []
        recommendation = nil
        isLoading = false
        errorMessage = nil
    }

    private var trimmedPlanPreference: String? {
        let value = planPreference.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}
