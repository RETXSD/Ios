import SwiftUI

struct AIAssistantView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AIAssistantViewModel

    let userId: String
    let profile: UserFitnessProfile?
    let exercises: [ExerciseCatalogItem]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerCard
                    recommendationCard
                    chatCard
                }
                .padding()
            }
            .background { FitnessTheme.pageBackground }
            .navigationTitle("AI Assistant")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: dismiss.callAsFunction)
                }
            }
        }
    }

    private var headerCard: some View {
        FitnessCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("AI Coach", systemImage: "sparkles")
                    .font(.headline)
                    .foregroundStyle(FitnessTheme.gold)

                Text("Ask for workout guidance or generate a plan from your profile, calorie target, available time, and exercise catalog.")
                    .font(.body)
                    .foregroundStyle(FitnessTheme.textMuted)
                    .fixedSize(horizontal: false, vertical: true)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.red)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var recommendationCard: some View {
        FitnessCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline) {
                    Label("AI Workout Plan", systemImage: "bolt.heart.fill")
                        .font(.headline)
                        .foregroundStyle(FitnessTheme.primary)

                    Spacer()

                if viewModel.isLoading {
                    ProgressView()
                        .tint(FitnessTheme.primary)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Plan request")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(FitnessTheme.textMuted)

                TextField("Example: no running today, low impact only", text: $viewModel.planPreference, axis: .vertical)
                    .lineLimit(2...)
                    .foregroundStyle(FitnessTheme.text)
                    .tint(FitnessTheme.primary)
                    .padding(12)
                    .frame(minHeight: 58, alignment: .topLeading)
                    .background(FitnessTheme.surface, in: RoundedRectangle(cornerRadius: FitnessTheme.controlRadius))
                    .overlay {
                        RoundedRectangle(cornerRadius: FitnessTheme.controlRadius)
                            .stroke(FitnessTheme.border, lineWidth: 1)
                    }
            }

            Button(action: generateRecommendation) {
                Label("Generate Plan", systemImage: "wand.and.stars")
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .tint(FitnessTheme.primary)
                .disabled(viewModel.isLoading || profile == nil)

                if let recommendation = viewModel.recommendation {
                    Text(recommendation.summary)
                        .font(.subheadline)
                        .foregroundStyle(FitnessTheme.textMuted)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack {
                        MetricPill("\(Int(recommendation.totalEstimatedCalories.rounded())) kcal", systemImage: "flame.fill")
                        MetricPill("\(recommendation.dailyWorkoutDurationMinutes) min", systemImage: "clock.fill")
                        MetricPill("AI", systemImage: "sparkles")
                    }

                    VStack(spacing: 10) {
                        ForEach(Array(recommendation.items.enumerated()), id: \.offset) { _, item in
                            recommendationRow(item)
                        }
                    }
                } else {
                    Text(profile == nil ? "Finish setup first so the AI can use your goals." : "Generate a plan when you want a profile-based recommendation.")
                        .font(.subheadline)
                        .foregroundStyle(FitnessTheme.textMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var chatCard: some View {
        FitnessCard {
            VStack(alignment: .leading, spacing: 14) {
                Label("Chat", systemImage: "message.fill")
                    .font(.headline)
                    .foregroundStyle(FitnessTheme.primary)

                if viewModel.messages.isEmpty {
                    Text("Ask anything about making the workout easier, harder, safer, or more focused.")
                        .font(.subheadline)
                        .foregroundStyle(FitnessTheme.textMuted)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    VStack(spacing: 10) {
                        ForEach(viewModel.messages) { message in
                            messageBubble(message)
                        }
                    }
                }

                TextField("Example: make this easier for beginners", text: $viewModel.prompt, axis: .vertical)
                    .lineLimit(3...)
                    .foregroundStyle(FitnessTheme.text)
                    .tint(FitnessTheme.primary)
                    .padding(12)
                    .frame(minHeight: 82, alignment: .topLeading)
                    .background(FitnessTheme.surface, in: RoundedRectangle(cornerRadius: FitnessTheme.controlRadius))
                    .overlay {
                        RoundedRectangle(cornerRadius: FitnessTheme.controlRadius)
                            .stroke(FitnessTheme.border, lineWidth: 1)
                    }

                Button(action: sendPrompt) {
                    Label("Send", systemImage: "paperplane.fill")
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .tint(FitnessTheme.primary)
                .disabled(viewModel.prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
            }
        }
    }

    private func recommendationRow(_ item: WorkoutRecommendationItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(item.name)
                    .font(.subheadline.bold())
                    .foregroundStyle(FitnessTheme.text)

                Spacer()

                Text("\(item.durationMinutes) min")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(FitnessTheme.ink)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(FitnessTheme.primary, in: Capsule())
            }

            Text(item.instructions)
                .font(.caption)
                .foregroundStyle(FitnessTheme.textMuted)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                MetricPill(item.intensity.rawValue.capitalized, systemImage: "speedometer")
                MetricPill("\(Int(item.estimatedCalories.rounded())) kcal", systemImage: "flame.fill")
            }
        }
        .padding(12)
        .background(FitnessTheme.surface, in: RoundedRectangle(cornerRadius: FitnessTheme.controlRadius))
        .overlay {
            RoundedRectangle(cornerRadius: FitnessTheme.controlRadius)
                .stroke(FitnessTheme.border, lineWidth: 1)
        }
    }

    private func messageBubble(_ message: AIMessage) -> some View {
        let isUser = message.role == .user

        return Text(message.content)
            .font(.subheadline)
            .foregroundStyle(isUser ? FitnessTheme.ink : FitnessTheme.text)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
            .background(
                isUser ? FitnessTheme.primary : FitnessTheme.surface,
                in: RoundedRectangle(cornerRadius: FitnessTheme.controlRadius)
            )
            .overlay {
                RoundedRectangle(cornerRadius: FitnessTheme.controlRadius)
                    .stroke(isUser ? FitnessTheme.primary : FitnessTheme.border, lineWidth: 1)
            }
            .accessibilityLabel(isUser ? "You said \(message.content)" : "AI said \(message.content)")
    }

    private func sendPrompt() {
        Task {
            await viewModel.sendMessage(userId: userId)
        }
    }

    private func generateRecommendation() {
        Task {
            await viewModel.generateRecommendation(
                profile: profile,
                exercises: exercises
            )
        }
    }
}
