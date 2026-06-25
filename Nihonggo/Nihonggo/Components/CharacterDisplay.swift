import SwiftUI

struct CharacterDisplay: View {
    let character: String
    let reading: String

    var body: some View {
        Text(character)
            .font(.system(.largeTitle, design: .serif))
            .fontWidth(.expanded)
            .bold()
            .foregroundStyle(AppTheme.toriiRed)
            .minimumScaleFactor(0.5)
            .frame(maxWidth: .infinity, minHeight: 150)
            .accessibilityLabel("Japanese character")
            .accessibilityValue(reading)
    }
}
