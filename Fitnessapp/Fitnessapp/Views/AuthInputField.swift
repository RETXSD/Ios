import SwiftUI

struct AuthInputField: View {
    let title: String
    let systemImage: String
    @Binding var text: String
    var isSecure = false
    var textContentType: UITextContentType?
    var keyboardType: UIKeyboardType = .default
    var capitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(FitnessTheme.textMuted)

            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(FitnessTheme.gold)
                    .frame(width: 22)
                    .accessibilityHidden(true)

                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text(title)
                            .foregroundStyle(FitnessTheme.textMuted.opacity(0.72))
                    }

                    inputField
                }
                .textContentType(textContentType)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(capitalization)
                .autocorrectionDisabled()
                .foregroundStyle(FitnessTheme.text)
                .tint(FitnessTheme.primary)
            }
            .padding(.horizontal, 14)
            .frame(minHeight: 52)
            .background(FitnessTheme.surface, in: RoundedRectangle(cornerRadius: FitnessTheme.controlRadius))
            .overlay {
                RoundedRectangle(cornerRadius: FitnessTheme.controlRadius)
                    .stroke(FitnessTheme.border, lineWidth: 1)
            }
        }
    }

    @ViewBuilder
    private var inputField: some View {
        if isSecure {
            SecureField(title, text: $text)
                .labelsHidden()
                .accessibilityLabel(title)
        } else {
            TextField(title, text: $text)
                .labelsHidden()
                .accessibilityLabel(title)
        }
    }
}
