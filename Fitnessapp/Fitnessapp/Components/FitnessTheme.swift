import SwiftUI

enum FitnessTheme {
    static let background = Color(red: 0.039, green: 0.039, blue: 0.039)
    static let surface = Color(red: 0.118, green: 0.118, blue: 0.118)
    static let surfaceRaised = Color(red: 0.078, green: 0.078, blue: 0.078)
    static let surfaceHigh = Color(red: 0.165, green: 0.165, blue: 0.165)
    static let tabBackground = Color(red: 0.059, green: 0.059, blue: 0.059)
    static let primary = Color(red: 0.776, green: 0.945, blue: 0.208)
    static let secondary = Color(red: 0.776, green: 0.945, blue: 0.208).opacity(0.15)
    static let gold = Color(red: 1.0, green: 0.722, blue: 0.0)
    static let error = Color(red: 1.0, green: 0.302, blue: 0.302)
    static let info = Color(red: 0.302, green: 0.651, blue: 1.0)
    static let primaryTint = Color(red: 0.776, green: 0.945, blue: 0.208).opacity(0.15)
    static let ink = Color(red: 0.039, green: 0.039, blue: 0.039)
    static let text = Color.white
    static let textMuted = Color.white.opacity(0.8)
    static let textTertiary = Color.white.opacity(0.44)
    static let border = Color.white.opacity(0.15)
    static let focusRing = Color(red: 0.776, green: 0.945, blue: 0.208)
    static let glow = Color(red: 0.776, green: 0.945, blue: 0.208).opacity(0.35)

    static let cardRadius: CGFloat = 16
    static let controlRadius: CGFloat = 12

    static var pageBackground: some View {
        background
            .ignoresSafeArea()
    }
}

struct FitnessPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(isEnabled ? FitnessTheme.ink : FitnessTheme.textTertiary)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(isEnabled ? FitnessTheme.primary : FitnessTheme.surfaceHigh, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(isEnabled ? FitnessTheme.primary.opacity(0.35) : FitnessTheme.border, lineWidth: 1)
            }
            .shadow(color: isEnabled ? FitnessTheme.glow : .clear, radius: 14, x: 0, y: 0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct FitnessSecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(isEnabled ? FitnessTheme.text : FitnessTheme.textTertiary)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(FitnessTheme.surface, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(FitnessTheme.border, lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct FitnessDestructiveButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(isEnabled ? FitnessTheme.error : FitnessTheme.textTertiary)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(FitnessTheme.error.opacity(0.12), in: Capsule())
            .overlay {
                Capsule()
                    .stroke(FitnessTheme.error.opacity(isEnabled ? 0.35 : 0.12), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
