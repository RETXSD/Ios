import SwiftUI

struct TodayHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)

            Text("Your calorie goal, active energy, and next workout.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}
