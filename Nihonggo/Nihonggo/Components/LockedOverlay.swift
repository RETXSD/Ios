import SwiftUI

struct LockedOverlay: View {
    let message: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "lock.fill")
                .font(.title2)
            Text(message)
                .font(.headline)
                .bold()
                .multilineTextAlignment(.center)
        }
        .foregroundStyle(AppTheme.washiWhite)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.sumiInk.opacity(0.92))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }
}
