import SwiftUI

struct SplashView: View {
    var body: some View {
        VStack(spacing: 18) {
            Text("日本語")
                .font(.system(.largeTitle, design: .serif))
                .bold()
                .foregroundStyle(AppTheme.toriiRed)
            Text("KanaLearn")
                .font(.largeTitle)
                .bold()
            AppBadge("Hiragana • Katakana • Kanji", color: AppTheme.kinkakuGold, systemImage: "sparkles")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .appScreenBackground()
        .accessibilityElement(children: .combine)
    }
}
