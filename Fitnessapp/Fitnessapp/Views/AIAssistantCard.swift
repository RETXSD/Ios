import SwiftUI

struct AIAssistantCard: View {
    let action: () -> Void

    var body: some View {
        FitnessCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("AI Assistant", systemImage: "sparkles")
                    .font(.headline)
                    .foregroundStyle(FitnessTheme.gold)

                Text("Ask for a workout plan based on your calorie target, duration, age, weight, and fitness level.")
                    .font(.subheadline)
                    .foregroundStyle(FitnessTheme.textMuted)

                Button(action: action) {
                    Label("Open AI Coach", systemImage: "message.fill")
                }
                    .buttonStyle(.bordered)
                    .tint(FitnessTheme.primary)
                    .frame(minHeight: 44)
            }
        }
    }
}
