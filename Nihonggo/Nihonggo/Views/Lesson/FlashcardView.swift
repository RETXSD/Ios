import SwiftUI

struct FlashcardView: View {
    let card: FlashCard
    let isShowingBack: Bool
    @ObservedObject var audioService: AudioService

    var body: some View {
        AppCard {
            if isShowingBack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(card.reading)
                            .font(.title)
                            .bold()
                        Text(card.meaning)
                            .font(.headline)
                        Text(card.exampleJP)
                            .font(.title3)
                            .bold()
                        Text("\(card.exampleReading) • \(card.exampleEN)")
                            .font(.body)
                    }
                    Spacer()
                    AudioButton(text: card.character, audioService: audioService)
                }
            } else {
                CharacterDisplay(character: card.character, reading: card.reading)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
