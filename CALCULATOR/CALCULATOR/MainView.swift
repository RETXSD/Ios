//
//  ContentView.swift
//  CALCULATOR
//

import SwiftUI

// MARK: - All Themes

struct CalcTheme {
    let id: String
    let name: String
    let emoji: String
    let background: Color
    let numberButton: Color
    let functionButton: Color
    let operatorButton: Color
    let operatorActive: Color
    let textPrimary: Color
    let textSecondary: Color
    let glassOverlay: Color
    let glassBorder: Color
    let glassHighlight: Color
    let accentGlow: Color

    static let all: [CalcTheme] = [spring, summer, autumn, winter, midnight, roseGold, forest, obsidian]

    // 🌸 SPRING
    static let spring = CalcTheme(
        id: "spring", name: "Spring", emoji: "🌸",
        background: Color(red: 1.0, green: 0.878, blue: 0.914),
        numberButton: Color(red: 0.988, green: 0.780, blue: 0.847),
        functionButton: Color(red: 0.961, green: 0.686, blue: 0.773),
        operatorButton: Color(red: 0.859, green: 0.290, blue: 0.533),
        operatorActive: .white,
        textPrimary: Color(red: 0.502, green: 0.067, blue: 0.224),
        textSecondary: Color(red: 0.502, green: 0.067, blue: 0.224).opacity(0.5),
        glassOverlay: Color.white.opacity(0.35),
        glassBorder: Color.white.opacity(0.55),
        glassHighlight: Color.white.opacity(0.65),
        accentGlow: Color(red: 0.859, green: 0.290, blue: 0.533).opacity(0.3)
    )

    // ☀️ SUMMER
    static let summer = CalcTheme(
        id: "summer", name: "Summer", emoji: "☀️",
        background: Color(red: 0.529, green: 0.808, blue: 0.922),
        numberButton: Color(red: 0.420, green: 0.733, blue: 0.878),
        functionButton: Color(red: 0.271, green: 0.639, blue: 0.831),
        operatorButton: Color(red: 1.0, green: 0.839, blue: 0.0),
        operatorActive: Color(red: 0.024, green: 0.325, blue: 0.627),
        textPrimary: Color(red: 0.024, green: 0.224, blue: 0.435),
        textSecondary: Color(red: 0.024, green: 0.224, blue: 0.435).opacity(0.5),
        glassOverlay: Color.white.opacity(0.2),
        glassBorder: Color.white.opacity(0.45),
        glassHighlight: Color.white.opacity(0.55),
        accentGlow: Color(red: 1.0, green: 0.839, blue: 0.0).opacity(0.4)
    )

    // 🍂 AUTUMN
    static let autumn = CalcTheme(
        id: "autumn", name: "Autumn", emoji: "🍂",
        background: Color(red: 0.255, green: 0.133, blue: 0.039),
        numberButton: Color(red: 0.365, green: 0.188, blue: 0.059),
        functionButton: Color(red: 0.471, green: 0.239, blue: 0.067),
        operatorButton: Color(red: 0.918, green: 0.416, blue: 0.094),
        operatorActive: .white,
        textPrimary: Color(red: 1.0, green: 0.878, blue: 0.671),
        textSecondary: Color(red: 1.0, green: 0.878, blue: 0.671).opacity(0.5),
        glassOverlay: Color.white.opacity(0.07),
        glassBorder: Color.white.opacity(0.18),
        glassHighlight: Color.white.opacity(0.14),
        accentGlow: Color(red: 0.918, green: 0.416, blue: 0.094).opacity(0.45)
    )

    // ❄️ WINTER
    static let winter = CalcTheme(
        id: "winter", name: "Winter", emoji: "❄️",
        background: Color(red: 0.063, green: 0.043, blue: 0.153),
        numberButton: Color(red: 0.102, green: 0.075, blue: 0.231),
        functionButton: Color(red: 0.149, green: 0.106, blue: 0.306),
        operatorButton: Color(red: 0.392, green: 0.714, blue: 0.965),
        operatorActive: Color(red: 0.063, green: 0.043, blue: 0.153),
        textPrimary: Color(red: 0.820, green: 0.918, blue: 0.988),
        textSecondary: Color(red: 0.820, green: 0.918, blue: 0.988).opacity(0.5),
        glassOverlay: Color.white.opacity(0.07),
        glassBorder: Color(red: 0.392, green: 0.714, blue: 0.965).opacity(0.25),
        glassHighlight: Color.white.opacity(0.12),
        accentGlow: Color(red: 0.392, green: 0.714, blue: 0.965).opacity(0.35)
    )

    // 🌃 MIDNIGHT
    static let midnight = CalcTheme(
        id: "midnight", name: "Midnight", emoji: "🌃",
        background: Color(red: 0.039, green: 0.082, blue: 0.137),
        numberButton: Color(red: 0.059, green: 0.118, blue: 0.200),
        functionButton: Color(red: 0.078, green: 0.153, blue: 0.251),
        operatorButton: Color(red: 0.376, green: 0.714, blue: 0.749),
        operatorActive: Color(red: 0.039, green: 0.082, blue: 0.137),
        textPrimary: Color(red: 0.659, green: 0.855, blue: 0.863),
        textSecondary: Color(red: 0.659, green: 0.855, blue: 0.863).opacity(0.5),
        glassOverlay: Color.white.opacity(0.05),
        glassBorder: Color(red: 0.376, green: 0.714, blue: 0.749).opacity(0.2),
        glassHighlight: Color.white.opacity(0.09),
        accentGlow: Color(red: 0.376, green: 0.714, blue: 0.749).opacity(0.3)
    )

    // 🌹 ROSE GOLD
    static let roseGold = CalcTheme(
        id: "roseGold", name: "Rose Gold", emoji: "🌹",
        background: Color(red: 0.988, green: 0.878, blue: 0.902),
        numberButton: Color(red: 0.973, green: 0.792, blue: 0.831),
        functionButton: Color(red: 0.941, green: 0.682, blue: 0.741),
        operatorButton: Color(red: 0.816, green: 0.573, blue: 0.353),
        operatorActive: .white,
        textPrimary: Color(red: 0.424, green: 0.149, blue: 0.224),
        textSecondary: Color(red: 0.424, green: 0.149, blue: 0.224).opacity(0.5),
        glassOverlay: Color.white.opacity(0.4),
        glassBorder: Color.white.opacity(0.6),
        glassHighlight: Color.white.opacity(0.7),
        accentGlow: Color(red: 0.816, green: 0.573, blue: 0.353).opacity(0.35)
    )

    // 🌲 FOREST
    static let forest = CalcTheme(
        id: "forest", name: "Forest", emoji: "🌲",
        background: Color(red: 0.047, green: 0.157, blue: 0.094),
        numberButton: Color(red: 0.063, green: 0.216, blue: 0.125),
        functionButton: Color(red: 0.094, green: 0.275, blue: 0.165),
        operatorButton: Color(red: 0.251, green: 0.706, blue: 0.345),
        operatorActive: Color(red: 0.047, green: 0.157, blue: 0.094),
        textPrimary: Color(red: 0.780, green: 0.988, blue: 0.827),
        textSecondary: Color(red: 0.780, green: 0.988, blue: 0.827).opacity(0.5),
        glassOverlay: Color.white.opacity(0.06),
        glassBorder: Color(red: 0.251, green: 0.706, blue: 0.345).opacity(0.2),
        glassHighlight: Color.white.opacity(0.1),
        accentGlow: Color(red: 0.251, green: 0.706, blue: 0.345).opacity(0.35)
    )

    // ✦ OBSIDIAN
    static let obsidian = CalcTheme(
        id: "obsidian", name: "Obsidian", emoji: "✦",
        background: Color(red: 0.067, green: 0.067, blue: 0.067),
        numberButton: Color(red: 0.118, green: 0.118, blue: 0.118),
        functionButton: Color(red: 0.157, green: 0.157, blue: 0.157),
        operatorButton: Color(red: 0.831, green: 0.686, blue: 0.216),
        operatorActive: Color(red: 0.067, green: 0.067, blue: 0.067),
        textPrimary: Color(red: 0.918, green: 0.816, blue: 0.502),
        textSecondary: Color(red: 0.918, green: 0.816, blue: 0.502).opacity(0.5),
        glassOverlay: Color.white.opacity(0.04),
        glassBorder: Color(red: 0.831, green: 0.686, blue: 0.216).opacity(0.25),
        glassHighlight: Color.white.opacity(0.07),
        accentGlow: Color(red: 0.831, green: 0.686, blue: 0.216).opacity(0.4)
    )
}

// MARK: - Enums & Models

enum CalcButtonType {
    case number(String)
    case operation(String)
    case function_(String)
    case equals
    case decimal
}

struct CalcButton: Identifiable {
    let id = UUID()
    let label: String
    let type: CalcButtonType
    let systemImage: String?

    init(label: String, type: CalcButtonType, systemImage: String? = nil) {
        self.label = label; self.type = type; self.systemImage = systemImage
    }

    func backgroundColor(theme: CalcTheme) -> Color {
        switch type {
        case .number, .decimal: return theme.numberButton
        case .function_:        return theme.functionButton
        case .operation, .equals: return theme.operatorButton
        }
    }
    func foregroundColor(theme: CalcTheme) -> Color { theme.textPrimary }
}

enum Operation {
    case add, subtract, multiply, divide, none
    var symbol: String {
        switch self {
        case .add: return "+"
        case .subtract: return "−"
        case .multiply: return "×"
        case .divide: return "÷"
        case .none: return ""
        }
    }
}

// MARK: - Theme Picker View

struct ThemePickerView: View {
    @Binding var selectedTheme: CalcTheme
    @Binding var isShowing: Bool

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header
            HStack {
                Text("Pilih Tema")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Button(action: { withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { isShowing = false } }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)

            // Section: 4 Seasons
            Text("4 MUSIM")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white.opacity(0.45))
                .tracking(1.5)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach([CalcTheme.spring, CalcTheme.summer, CalcTheme.autumn, CalcTheme.winter], id: \.id) { theme in
                    ThemeCardView(theme: theme, isSelected: selectedTheme.id == theme.id) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTheme = theme
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { isShowing = false }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)

            // Section: Elegant
            Text("ELEGAN")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white.opacity(0.45))
                .tracking(1.5)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 10)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach([CalcTheme.midnight, CalcTheme.roseGold, CalcTheme.forest, CalcTheme.obsidian], id: \.id) { theme in
                    ThemeCardView(theme: theme, isSelected: selectedTheme.id == theme.id) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTheme = theme
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { isShowing = false }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.1, green: 0.1, blue: 0.12).opacity(0.97))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.5), radius: 40, x: 0, y: 20)
    }
}

// MARK: - Theme Card View

struct ThemeCardView: View {
    let theme: CalcTheme
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Art area
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.background)
                        .frame(height: 64)

                    // Mini art per tema
                    ThemeMiniArt(theme: theme)
                        .frame(height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.white, lineWidth: 2.5)
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.4), radius: 4)
                    }
                }

                // Label
                VStack(spacing: 1) {
                    Text(theme.emoji)
                        .font(.system(size: 11))
                    Text(theme.name)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }
                .padding(.vertical, 6)
            }
        }
        .buttonStyle(ThemeCardButtonStyle())
        .scaleEffect(isSelected ? 1.04 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct ThemeCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Mini Art per Tema (abstract accent shapes)

struct ThemeMiniArt: View {
    let theme: CalcTheme

    var body: some View {
        ZStack {
            switch theme.id {
            case "spring":
                // Sakura circles
                Circle().fill(Color(red: 1.0, green: 0.718, blue: 0.773)).frame(width: 32, height: 32).offset(x: -18, y: -8)
                Circle().fill(Color(red: 0.988, green: 0.565, blue: 0.647)).frame(width: 24, height: 24).offset(x: 10, y: -14)
                Circle().fill(Color(red: 1.0, green: 0.824, blue: 0.859)).frame(width: 20, height: 20).offset(x: 22, y: 4)
                Circle().fill(Color(red: 0.980, green: 0.663, blue: 0.729)).frame(width: 16, height: 16).offset(x: -28, y: 12)
            case "summer":
                // Sun + waves
                Circle().fill(Color(red: 1.0, green: 0.859, blue: 0.0)).frame(width: 28, height: 28).offset(x: 20, y: -14)
                RoundedRectangle(cornerRadius: 4).fill(Color(red: 0.161, green: 0.714, blue: 0.965)).frame(width: 60, height: 14).offset(y: 18)
                RoundedRectangle(cornerRadius: 4).fill(Color(red: 0.227, green: 0.627, blue: 0.878)).frame(width: 70, height: 10).offset(y: 26)
            case "autumn":
                // Leaf shapes
                Ellipse().fill(Color(red: 0.918, green: 0.416, blue: 0.094)).frame(width: 28, height: 18).rotationEffect(.degrees(-30)).offset(x: -16, y: -8)
                Ellipse().fill(Color(red: 0.800, green: 0.267, blue: 0.051)).frame(width: 22, height: 14).rotationEffect(.degrees(20)).offset(x: 12, y: -12)
                Ellipse().fill(Color(red: 0.961, green: 0.588, blue: 0.157)).frame(width: 26, height: 16).rotationEffect(.degrees(-15)).offset(x: 18, y: 10)
                Ellipse().fill(Color(red: 0.824, green: 0.353, blue: 0.071)).frame(width: 20, height: 12).rotationEffect(.degrees(35)).offset(x: -22, y: 14)
            case "winter":
                // Aurora curves + stars
                Capsule().fill(Color(red: 0.392, green: 0.714, blue: 0.965).opacity(0.5)).frame(width: 80, height: 8).rotationEffect(.degrees(-12)).offset(y: -10)
                Capsule().fill(Color(red: 0.541, green: 0.886, blue: 0.647).opacity(0.4)).frame(width: 70, height: 6).rotationEffect(.degrees(-8)).offset(y: 2)
                Capsule().fill(Color(red: 0.878, green: 0.502, blue: 0.965).opacity(0.35)).frame(width: 75, height: 5).rotationEffect(.degrees(-5)).offset(y: 12)
                Circle().fill(Color.white).frame(width: 3, height: 3).offset(x: -28, y: -20)
                Circle().fill(Color.white).frame(width: 2, height: 2).offset(x: 10, y: -24)
                Circle().fill(Color.white).frame(width: 2.5, height: 2.5).offset(x: 30, y: -18)
            case "midnight":
                // City lights
                Rectangle().fill(Color(red: 0.078, green: 0.153, blue: 0.251)).frame(width: 12, height: 28).offset(x: -22, y: 14)
                Rectangle().fill(Color(red: 0.063, green: 0.137, blue: 0.224)).frame(width: 16, height: 36).offset(x: -4, y: 10)
                Rectangle().fill(Color(red: 0.078, green: 0.153, blue: 0.251)).frame(width: 14, height: 30).offset(x: 14, y: 12)
                Rectangle().fill(Color(red: 0.059, green: 0.118, blue: 0.200)).frame(width: 10, height: 24).offset(x: 28, y: 16)
                // Window lights
                Group {
                    Circle().fill(theme.operatorButton.opacity(0.8)).frame(width: 2, height: 2).offset(x: -22, y: -2)
                    Circle().fill(theme.operatorButton.opacity(0.6)).frame(width: 2, height: 2).offset(x: -4, y: -6)
                    Circle().fill(theme.operatorButton.opacity(0.7)).frame(width: 2, height: 2).offset(x: 14, y: -2)
                    Circle().fill(theme.operatorButton.opacity(0.5)).frame(width: 2, height: 2).offset(x: -4, y: 4)
                }
            case "roseGold":
                // Rose petals + gold dots
                Circle().fill(Color(red: 0.878, green: 0.471, blue: 0.600)).frame(width: 26, height: 26).offset(x: 0, y: -8)
                Circle().fill(Color(red: 0.941, green: 0.608, blue: 0.710)).frame(width: 20, height: 20).offset(x: -14, y: 4)
                Circle().fill(Color(red: 0.820, green: 0.400, blue: 0.533)).frame(width: 18, height: 18).offset(x: 14, y: 4)
                Circle().fill(Color(red: 0.816, green: 0.686, blue: 0.216)).frame(width: 6, height: 6).offset(x: 26, y: -18)
                Circle().fill(Color(red: 0.816, green: 0.686, blue: 0.216)).frame(width: 4, height: 4).offset(x: -28, y: -16)
                Circle().fill(Color(red: 0.816, green: 0.686, blue: 0.216)).frame(width: 5, height: 5).offset(x: 20, y: 18)
            case "forest":
                // Trees silhouette
                Triangle().fill(Color(red: 0.110, green: 0.369, blue: 0.192)).frame(width: 28, height: 34).offset(x: -20, y: 8)
                Triangle().fill(Color(red: 0.094, green: 0.322, blue: 0.165)).frame(width: 22, height: 28).offset(x: -4, y: 12)
                Triangle().fill(Color(red: 0.157, green: 0.439, blue: 0.251)).frame(width: 30, height: 36).offset(x: 14, y: 6)
                Triangle().fill(Color(red: 0.110, green: 0.369, blue: 0.192)).frame(width: 20, height: 26).offset(x: 30, y: 14)
                // Firefly dots
                Circle().fill(Color(red: 0.565, green: 0.933, blue: 0.565).opacity(0.9)).frame(width: 3, height: 3).offset(x: -8, y: -8)
                Circle().fill(Color(red: 0.690, green: 1.0, blue: 0.541).opacity(0.8)).frame(width: 2.5, height: 2.5).offset(x: 6, y: -14)
            case "obsidian":
                // Gold diamond geometric
                Rectangle().fill(Color(red: 0.831, green: 0.686, blue: 0.216).opacity(0.15)).frame(width: 56, height: 56).rotationEffect(.degrees(45)).offset(y: 4)
                Rectangle().fill(Color.clear).frame(width: 40, height: 40).rotationEffect(.degrees(45))
                    .overlay(
                        Rectangle().stroke(Color(red: 0.831, green: 0.686, blue: 0.216).opacity(0.6), lineWidth: 1).rotationEffect(.degrees(45))
                    )
                Circle().fill(Color(red: 0.831, green: 0.686, blue: 0.216)).frame(width: 6, height: 6)
            default:
                EmptyView()
            }
        }
    }
}

// MARK: - Triangle Shape Helper

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - ContentView

struct ContentView: View {
    @State private var displayValue: String = "0"
    @State private var currentNumber: Double = 0
    @State private var previousNumber: Double = 0
    @State private var currentOperation: Operation = .none
    @State private var isTypingNumber: Bool = false
    @State private var activeOperator: String? = nil
    @State private var justCalculated: Bool = false
    @State private var pendingOperatorSymbol: String = ""
    @State private var expressionHistory: String = ""
    @State private var selectedTheme: CalcTheme = .all[0]  // default: Spring
    @State private var showThemePicker: Bool = false

    private var theme: CalcTheme { selectedTheme }

    private let buttons: [[CalcButton]] = [
        [
            CalcButton(label: "⌫", type: .function_("backspace"), systemImage: "delete.backward"),
            CalcButton(label: "AC", type: .function_("AC")),
            CalcButton(label: "%", type: .function_("%")),
            CalcButton(label: "÷", type: .operation("÷")),
        ],
        [
            CalcButton(label: "7", type: .number("7")), CalcButton(label: "8", type: .number("8")),
            CalcButton(label: "9", type: .number("9")), CalcButton(label: "×", type: .operation("×")),
        ],
        [
            CalcButton(label: "4", type: .number("4")), CalcButton(label: "5", type: .number("5")),
            CalcButton(label: "6", type: .number("6")), CalcButton(label: "−", type: .operation("−")),
        ],
        [
            CalcButton(label: "1", type: .number("1")), CalcButton(label: "2", type: .number("2")),
            CalcButton(label: "3", type: .number("3")), CalcButton(label: "+", type: .operation("+")),
        ],
        [
            CalcButton(label: "+/−", type: .function_("±")), CalcButton(label: "0", type: .number("0")),
            CalcButton(label: ".", type: .decimal),         CalcButton(label: "=", type: .equals),
        ],
    ]

    private var displayText: String {
        if justCalculated { return formatDisplay(displayValue) }
        if currentOperation != .none && !isTypingNumber {
            return formatDisplay(formatResult(previousNumber)) + currentOperation.symbol
        }
        if currentOperation != .none && isTypingNumber {
            return formatDisplay(formatResult(previousNumber)) + pendingOperatorSymbol + formatDisplay(displayValue)
        }
        return formatDisplay(displayValue)
    }

    var body: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 14
            let hPad: CGFloat = 16
            let availableWidth = geometry.size.width - (hPad * 2) - (spacing * 3)
            let buttonSize: CGFloat = availableWidth / 4

            ZStack(alignment: .top) {
                // Background
                theme.background.ignoresSafeArea()
                RadialGradient(
                    gradient: Gradient(colors: [theme.accentGlow, Color.clear]),
                    center: .top, startRadius: 50, endRadius: 400
                ).ignoresSafeArea()

                // Main layout
                VStack(spacing: 0) {
                    Spacer()

                    // Theme toggle button
                    HStack {
                        Button(action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                                showThemePicker.toggle()
                            }
                        }) {
                            HStack(spacing: 6) {
                                Text(theme.emoji)
                                    .font(.system(size: 15))
                                Image(systemName: "swatchpalette.fill")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(theme.textPrimary.opacity(0.8))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(theme.functionButton)
                                    .overlay(Capsule().fill(theme.glassOverlay))
                                    .overlay(Capsule().strokeBorder(theme.glassBorder.opacity(0.6), lineWidth: 0.8))
                            )
                        }
                        .buttonStyle(GlassButtonStyle())
                        .padding(.leading, hPad)
                        Spacer()
                    }
                    .padding(.bottom, 8)

                    // Expression history
                    HStack {
                        Spacer()
                        Text(expressionHistory)
                            .font(.system(size: 22, weight: .light))
                            .foregroundColor(theme.textSecondary)
                            .lineLimit(1).minimumScaleFactor(0.5)
                            .padding(.horizontal, 24).padding(.bottom, 6)
                    }
                    .frame(height: 28)

                    // Main display
                    HStack {
                        Spacer()
                        Text(displayText)
                            .font(.system(size: displayFontSize(for: displayText), weight: .light))
                            .foregroundColor(theme.textPrimary)
                            .lineLimit(1).minimumScaleFactor(0.35)
                            .padding(.horizontal, 20).padding(.bottom, 16)
                    }

                    // Button grid
                    VStack(spacing: spacing) {
                        ForEach(0..<buttons.count, id: \.self) { row in
                            HStack(spacing: spacing) {
                                ForEach(buttons[row]) { button in
                                    GlassButtonView(button: button, size: buttonSize,
                                                    isActive: activeOperator == button.label,
                                                    theme: theme) {
                                        handleButtonPress(button)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, hPad)
                    .padding(.bottom, 32)
                }

                // Theme Picker Popup (slide from top)
                if showThemePicker {
                    VStack {
                        ThemePickerView(selectedTheme: $selectedTheme, isShowing: $showThemePicker)
                            .padding(.horizontal, 12)
                            .padding(.top, 60)
                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(10)
                    .onTapGesture { } // block passthrough
                }

                // Tap outside to dismiss
                if showThemePicker {
                    Color.black.opacity(0.0001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                showThemePicker = false
                            }
                        }
                        .zIndex(9)
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: theme.id)
        }
    }

    // MARK: - Display Helpers

    private func displayFontSize(for value: String) -> CGFloat {
        let l = value.count
        if l <= 6 { return 80 }
        if l <= 9 { return 64 }
        if l <= 12 { return 48 }
        return 36
    }

    private func formatDisplay(_ value: String) -> String {
        if value == "Error" { return value }
        if value.hasSuffix(".") { return formatWithCommas(value) }
        guard let number = Double(value) else { return value }
        if number == floor(number) && !value.contains(".") && abs(number) < 1e15 {
            let f = NumberFormatter(); f.numberStyle = .decimal; f.maximumFractionDigits = 0
            return f.string(from: NSNumber(value: number)) ?? value
        }
        let f = NumberFormatter(); f.numberStyle = .decimal
        f.maximumFractionDigits = 8; f.minimumFractionDigits = 0
        return f.string(from: NSNumber(value: number)) ?? value
    }

    private func formatWithCommas(_ value: String) -> String {
        let parts = value.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
        guard let intPart = parts.first else { return value }
        let isNeg = intPart.hasPrefix("-")
        let digits = isNeg ? String(intPart.dropFirst()) : String(intPart)
        guard let intVal = Int(digits) else { return value }
        let f = NumberFormatter(); f.numberStyle = .decimal
        var fmt = f.string(from: NSNumber(value: intVal)) ?? String(digits)
        if isNeg { fmt = "-" + fmt }
        if parts.count > 1 { fmt += "." + String(parts[1]) } else if value.hasSuffix(".") { fmt += "." }
        return fmt
    }

    // MARK: - Button Handlers

    private func handleButtonPress(_ button: CalcButton) {
        switch button.type {
        case .number(let n):    handleNumber(n)
        case .decimal:          handleDecimal()
        case .operation(let o): handleOperation(o)
        case .function_(let f): handleFunction(f)
        case .equals:           handleEquals()
        }
    }

    private func handleNumber(_ num: String) {
        if justCalculated {
            expressionHistory = ""; displayValue = num
            isTypingNumber = true; justCalculated = false
            activeOperator = nil; pendingOperatorSymbol = ""; return
        }
        if isTypingNumber {
            if displayValue.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: ".", with: "").count < 9 {
                displayValue = (displayValue == "0") ? num : displayValue + num
            }
        } else {
            displayValue = num; isTypingNumber = true
        }
        activeOperator = nil
    }

    private func handleDecimal() {
        if justCalculated {
            expressionHistory = ""; displayValue = "0."
            isTypingNumber = true; justCalculated = false
            activeOperator = nil; pendingOperatorSymbol = ""; return
        }
        if isTypingNumber { if !displayValue.contains(".") { displayValue += "." } }
        else { displayValue = "0."; isTypingNumber = true }
        activeOperator = nil
    }

    private func handleOperation(_ op: String) {
        if isTypingNumber && currentOperation != .none && !justCalculated {
            previousNumber = calculate(previousNumber, curr: Double(displayValue) ?? 0)
            displayValue = formatResult(previousNumber)
            expressionHistory = formatDisplay(formatResult(previousNumber)) + " " + op
        } else {
            previousNumber = Double(displayValue) ?? 0
            expressionHistory = formatDisplay(displayValue) + " " + op
        }
        currentOperation = opFromSymbol(op); pendingOperatorSymbol = op
        isTypingNumber = false; justCalculated = false; activeOperator = op
    }

    private func handleFunction(_ fn: String) {
        switch fn {
        case "backspace":
            if isTypingNumber && displayValue != "0" {
                if displayValue.count <= 1 || (displayValue.count == 2 && displayValue.hasPrefix("-")) {
                    displayValue = "0"; isTypingNumber = false
                } else { displayValue = String(displayValue.dropLast()) }
            }
        case "AC":
            displayValue = "0"; currentNumber = 0; previousNumber = 0
            currentOperation = .none; isTypingNumber = false; activeOperator = nil
            justCalculated = false; pendingOperatorSymbol = ""; expressionHistory = ""
        case "±":
            if let v = Double(displayValue), v != 0 {
                displayValue = displayValue.hasPrefix("-") ? String(displayValue.dropFirst()) : "-" + displayValue
            }
        case "%":
            if let v = Double(displayValue) { displayValue = formatResult(v / 100); isTypingNumber = false }
        default: break
        }
    }

    private func handleEquals() {
        guard currentOperation != .none else { return }
        currentNumber = Double(displayValue) ?? 0
        expressionHistory = formatDisplay(formatResult(previousNumber)) + " " + currentOperation.symbol + " " + formatDisplay(displayValue) + " ="
        displayValue = formatResult(calculate(previousNumber, curr: currentNumber))
        currentOperation = .none; isTypingNumber = false
        justCalculated = true; activeOperator = nil; pendingOperatorSymbol = ""
    }

    private func calculate(_ prev: Double, curr: Double) -> Double {
        switch currentOperation {
        case .add:      return prev + curr
        case .subtract: return prev - curr
        case .multiply: return prev * curr
        case .divide:   return curr != 0 ? prev / curr : .nan
        case .none:     return curr
        }
    }

    private func opFromSymbol(_ s: String) -> Operation {
        switch s {
        case "+": return .add;   case "−": return .subtract
        case "×": return .multiply; case "÷": return .divide
        default:  return .none
        }
    }

    private func formatResult(_ value: Double) -> String {
        if value.isNaN || value.isInfinite { return "Error" }
        if value == floor(value) && abs(value) < 1e15 { return String(format: "%.0f", value) }
        var r = String(format: "%.8f", value)
        while r.hasSuffix("0") { r = String(r.dropLast()) }
        if r.hasSuffix(".") { r = String(r.dropLast()) }
        return r
    }
}

// MARK: - Glass Button View

struct GlassButtonView: View {
    let button: CalcButton
    let size: CGFloat
    let isActive: Bool
    let theme: CalcTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle().fill(buttonBackground).frame(width: size, height: size)
                Circle().fill(
                    LinearGradient(
                        gradient: Gradient(colors: [theme.glassHighlight, Color.clear, Color.black.opacity(0.05)]),
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                ).frame(width: size, height: size)
                Circle().fill(theme.glassOverlay).frame(width: size, height: size)
                Circle().strokeBorder(
                    LinearGradient(
                        gradient: Gradient(colors: [theme.glassBorder, Color.clear, theme.glassBorder.opacity(0.3)]),
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ), lineWidth: 0.8
                ).frame(width: size, height: size)

                if let sys = button.systemImage {
                    Image(systemName: sys)
                        .font(.system(size: fontSize, weight: .medium))
                        .foregroundColor(buttonForeground)
                } else {
                    Text(button.label)
                        .font(.system(size: fontSize, weight: .medium))
                        .foregroundColor(buttonForeground)
                }
            }
            .frame(width: size, height: size)
            .shadow(color: shadowColor, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(GlassButtonStyle())
    }

    private var fontSize: CGFloat {
        switch button.type {
        case .operation, .equals: return size * 0.4
        case .function_:
            if button.systemImage != nil { return size * 0.28 }
            if button.label == "+/−" { return size * 0.28 }
            return size * 0.3
        default: return size * 0.38
        }
    }

    private var buttonBackground: Color {
        isActive ? theme.operatorActive : button.backgroundColor(theme: theme)
    }
    private var buttonForeground: Color {
        isActive ? theme.operatorButton : button.foregroundColor(theme: theme)
    }
    private var shadowColor: Color {
        switch button.type {
        case .operation, .equals: return isActive ? .clear : theme.operatorButton.opacity(0.4)
        default: return Color.black.opacity(0.2)
        }
    }
}

// MARK: - Glass Button Style

struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}