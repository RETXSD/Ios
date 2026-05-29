import SwiftUI

struct AuthHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(FitnessTheme.secondary.opacity(0.18))
                    .frame(width: 54, height: 54)

                Image(systemName: "flame.fill")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(FitnessTheme.gold)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Fitness Coach")
                    .font(.largeTitle.bold())
                    .foregroundStyle(FitnessTheme.text)

                Text("Save your goals locally and focus on testing camera-based workout feedback first.")
                    .font(.body)
                    .foregroundStyle(FitnessTheme.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.top, 12)
        .accessibilityElement(children: .combine)
    }
}
