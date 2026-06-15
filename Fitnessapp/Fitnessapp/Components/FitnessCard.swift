import SwiftUI

struct FitnessCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(FitnessTheme.primary)
                .frame(width: 3)
                .padding(.vertical, 16)
                .opacity(0.95)

            content
                .padding(18)
                .padding(.leading, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(FitnessTheme.surfaceRaised, in: RoundedRectangle(cornerRadius: FitnessTheme.cardRadius))
        .overlay {
            RoundedRectangle(cornerRadius: FitnessTheme.cardRadius)
                .stroke(FitnessTheme.border, lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.42), radius: 22, x: 0, y: 14)
        .shadow(color: FitnessTheme.glow.opacity(0.22), radius: 14, x: 0, y: 0)
    }
}

struct FitnessPlainCard<Content: View>: View {
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
            .shadow(color: .black.opacity(0.36), radius: 18, x: 0, y: 10)
    }
}
