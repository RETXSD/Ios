import SwiftUI

enum FitnessTheme {
    static let background = Color(red: 0.082, green: 0.059, blue: 0.137)
    static let surface = Color(red: 0.122, green: 0.086, blue: 0.2)
    static let surfaceRaised = Color(red: 0.153, green: 0.118, blue: 0.26)
    static let primary = Color(red: 0.757, green: 0.937, blue: 0.306)
    static let secondary = Color(red: 0.416, green: 0.373, blue: 0.757)
    static let gold = Color(red: 0.98, green: 0.498, blue: 0.667)
    static let violetDeep = Color(red: 0.259, green: 0.125, blue: 0.51)
    static let ink = Color(red: 0.122, green: 0.086, blue: 0.2)
    static let text = Color.white
    static let textMuted = Color(red: 0.741, green: 0.722, blue: 0.753)
    static let border = Color(red: 0.212, green: 0.176, blue: 0.349)
    static let focusRing = Color(red: 0.616, green: 0.757, blue: 0.961)

    static let cardRadius: CGFloat = 12
    static let controlRadius: CGFloat = 8

    static var pageBackground: some View {
        background
            .ignoresSafeArea()
    }
}
