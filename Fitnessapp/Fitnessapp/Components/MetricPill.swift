import SwiftUI

struct MetricPill: View {
    let title: String
    let systemImage: String?

    init(_ title: String, systemImage: String? = nil) {
        self.title = title
        self.systemImage = systemImage
    }

    var body: some View {
        Group {
            if let systemImage {
                Label(title, systemImage: systemImage)
            } else {
                Text(title)
            }
        }
        .font(.caption.bold())
        .foregroundStyle(FitnessTheme.primary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(FitnessTheme.primary.opacity(0.15), in: Capsule())
        .overlay {
            Capsule()
                .stroke(FitnessTheme.primary.opacity(0.3), lineWidth: 1)
        }
    }
}
