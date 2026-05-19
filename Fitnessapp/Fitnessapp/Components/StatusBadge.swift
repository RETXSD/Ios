import SwiftUI

struct StatusBadge: View {
    let title: String
    let status: AppReadinessItemStatus

    var body: some View {
        Label(title, systemImage: symbolName)
            .font(.caption.bold())
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.14), in: Capsule())
            .accessibilityElement(children: .combine)
    }

    private var color: Color {
        switch status {
        case .ready:
            return .green
        case .needsAttention:
            return FitnessTheme.secondary
        case .blocked:
            return .red
        case .notChecked:
            return .gray
        }
    }

    private var symbolName: String {
        switch status {
        case .ready:
            return "checkmark.circle.fill"
        case .needsAttention:
            return "exclamationmark.triangle.fill"
        case .blocked:
            return "xmark.octagon.fill"
        case .notChecked:
            return "circle.dashed"
        }
    }
}
