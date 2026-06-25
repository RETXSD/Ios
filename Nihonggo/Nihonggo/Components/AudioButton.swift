import SwiftUI

struct AudioButton: View {
    let text: String
    @ObservedObject var audioService: AudioService

    var body: some View {
        Button(action: {
            audioService.speak(text)
        }) {
            Label("Play pronunciation", systemImage: "speaker.wave.2.fill")
        }
        .labelStyle(.iconOnly)
        .font(.title3)
        .frame(width: 44, height: 44)
        .foregroundStyle(AppTheme.sumiInk)
        .background(AppTheme.kinkakuGold)
        .overlay {
            Circle().stroke(AppTheme.sumiInk, lineWidth: AppTheme.borderWidth)
        }
        .clipShape(Circle())
        .flatShadow()
        .accessibilityHint("Speaks the Japanese text using ja-JP voice")
    }
}
