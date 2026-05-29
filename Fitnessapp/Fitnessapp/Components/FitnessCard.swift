import SwiftUI

struct FitnessCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(FitnessTheme.surfaceRaised, in: RoundedRectangle(cornerRadius: FitnessTheme.cardRadius))
            .overlay {
                RoundedRectangle(cornerRadius: FitnessTheme.cardRadius)
                    .stroke(FitnessTheme.border, lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.16), radius: 18, x: 0, y: 10)
    }
}
