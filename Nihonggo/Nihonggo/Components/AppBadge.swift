import SwiftUI

struct AppBadge: View {
    let text: String
    let color: Color
    let systemImage: String?

    init(_ text: String, color: Color = AppTheme.kinkakuGold, systemImage: String? = nil) {
        self.text = text
        self.color = color
        self.systemImage = systemImage
    }

    var body: some View {
        HStack(spacing: 5) {
            if let systemImage {
                Image(systemName: systemImage)
            }
            Text(text)
        }
            .font(.caption)
            .bold()
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(AppTheme.sumiInk)
            .background(color)
            .overlay {
                Capsule().stroke(AppTheme.sumiInk, lineWidth: AppTheme.borderWidth)
            }
            .clipShape(Capsule())
            .accessibilityLabel(text)
    }
}
