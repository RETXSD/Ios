import SwiftUI

struct AppCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.washiWhite)
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.cardRadius)
                .stroke(AppTheme.sumiInk, lineWidth: AppTheme.borderWidth)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
        .flatShadow()
    }
}
