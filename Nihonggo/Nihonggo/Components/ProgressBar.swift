import SwiftUI

struct ProgressBar: View {
    let progress: Double
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline)
                .bold()

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppTheme.sakuraBlush)
                    .frame(height: 18)

                Capsule()
                    .fill(AppTheme.toriiRed)
                    .frame(maxWidth: max(18, CGFloat(progress) * 280), minHeight: 18, maxHeight: 18)
            }
            .frame(maxWidth: 280, alignment: .leading)
            .overlay {
                Capsule().stroke(AppTheme.sumiInk, lineWidth: AppTheme.borderWidth)
            }
            .accessibilityLabel(label)
            .accessibilityValue(progress.formatted(.percent.precision(.fractionLength(0))))
        }
    }
}
