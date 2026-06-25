import SwiftUI

struct ConfidenceBadge: View {
    let confidence: Double

    var body: some View {
        AppBadge(
            confidence.formatted(.percent.precision(.fractionLength(0))),
            color: color,
            systemImage: systemImage
        )
        .accessibilityLabel("Confidence")
        .accessibilityValue(confidence.formatted(.percent.precision(.fractionLength(0))))
    }

    private var color: Color {
        if confidence >= 0.8 {
            return AppTheme.successGreen
        } else if confidence >= 0.5 {
            return AppTheme.kinkakuGold
        } else {
            return AppTheme.toriiRed
        }
    }

    private var systemImage: String {
        if confidence >= 0.8 {
            return "checkmark.circle.fill"
        } else if confidence >= 0.5 {
            return "exclamationmark.triangle.fill"
        } else {
            return "xmark.octagon.fill"
        }
    }
}
