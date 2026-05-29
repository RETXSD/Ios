import SwiftUI

struct StatusBadge: View {
    let title: String
    let status: AppReadinessItemStatus

    var body: some View {
        Label(title, systemImage: symbolName)
            .font(.caption.bold())
            .foregroundStyle(status == .ready ? FitnessTheme.ink : color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 6))
            .accessibilityElement(children: .combine)
    }

    private var backgroundColor: Color {
        switch status {
        case .ready:
            return FitnessTheme.primary
        case .needsAttention:
            return FitnessTheme.gold.opacity(0.18)
        case .blocked:
            return .red.opacity(0.18)
        case .notChecked:
            return FitnessTheme.surface
        }
    }

    private var color: Color {
        switch status {
        case .ready:
            return FitnessTheme.primary
        case .needsAttention:
            return FitnessTheme.gold
        case .blocked:
            return .red
        case .notChecked:
            return FitnessTheme.textMuted
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
