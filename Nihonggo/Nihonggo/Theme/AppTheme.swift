import SwiftUI

enum AppTheme {
    static let toriiRed = Color(hex: "#C62828")
    static let sakuraBlush = Color(hex: "#FFEBEE")
    static let sumiInk = Color(hex: "#1A1A2E")
    static let washiWhite = Color(hex: "#FDFAF5")
    static let tatamiCream = Color(hex: "#F5EFE0")
    static let kinkakuGold = Color(hex: "#C9962A")
    static let successGreen = Color.green

    static let borderWidth: Double = 2
    static let cardRadius: Double = 7
    static let shadowOffset: Double = 4
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255

        self.init(red: red, green: green, blue: blue)
    }
}

extension View {
    func appScreenBackground() -> some View {
        background(AppTheme.tatamiCream.ignoresSafeArea())
    }

    func flatShadow(collapsed: Bool = false) -> some View {
        shadow(
            color: AppTheme.sumiInk,
            radius: 0,
            x: collapsed ? 1 : AppTheme.shadowOffset,
            y: collapsed ? 1 : AppTheme.shadowOffset
        )
    }
}
