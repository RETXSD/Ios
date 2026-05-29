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
        .foregroundStyle(FitnessTheme.text)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(FitnessTheme.violetDeep, in: RoundedRectangle(cornerRadius: 6))
        .overlay {
            RoundedRectangle(cornerRadius: 6)
                .stroke(FitnessTheme.border, lineWidth: 1)
        }
    }
}
