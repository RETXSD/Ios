import SwiftUI

struct HomeCalorieCard: View {
    let progress: CalorieProgress
    let isLoading: Bool

    var body: some View {
        FitnessCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .center, spacing: 18) {
                    CalorieProgressRing(progress: progress)

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Active Energy", systemImage: "flame.fill")
                            .font(.headline)
                            .foregroundStyle(FitnessTheme.secondary)

                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(progress.activeEnergyBurned, format: .number.precision(.fractionLength(0)))
                                .font(.system(.largeTitle, design: .rounded).bold())
                                .foregroundStyle(.white)

                            Text("kcal")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }

                        Text("\(Int(progress.remaining)) kcal remaining from a \(Int(progress.goal)) kcal goal")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                if isLoading {
                    ProgressView()
                        .tint(FitnessTheme.secondary)
                        .accessibilityLabel("Loading dashboard")
                }
            }
        }
    }
}
