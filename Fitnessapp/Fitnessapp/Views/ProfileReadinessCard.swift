import SwiftUI

struct ProfileReadinessCard: View {
    let items: [AppReadinessItem]

    var body: some View {
        FitnessCard {
            VStack(alignment: .leading, spacing: 14) {
                Label("App Readiness", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .foregroundStyle(FitnessTheme.gold)

                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(item.title)
                                .font(.subheadline.bold())
                                .foregroundStyle(.white)

                            Spacer()

                            StatusBadge(title: item.status.rawValue, status: item.status)
                        }

                        Text(item.detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
