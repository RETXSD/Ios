//
//  ContentView.swift
//  24-point
//
//  Created by 11 on 2026/3/31.
//

import SwiftUI

// MARK: - Theme

struct AppTheme {
    let name: String
    let background: Color
    let cardBackground: Color
    let cardText: Color
    let buttonBackground: Color
    let buttonText: Color
    let accent: Color
    let exprBackground: Color
    let exprText: Color
    let secondaryText: Color
}

let themes: [AppTheme] = [
    AppTheme(
        name: "Classic",
        background: Color(UIColor.systemBackground),
        cardBackground: Color(UIColor.secondarySystemBackground),
        cardText: Color.primary,
        buttonBackground: Color(UIColor.tertiarySystemBackground),
        buttonText: Color.primary,
        accent: Color.blue,
        exprBackground: Color(UIColor.secondarySystemBackground),
        exprText: Color.primary,
        secondaryText: Color.secondary
    ),
    AppTheme(
        name: "Dark",
        background: Color(red: 0.1, green: 0.1, blue: 0.12),
        cardBackground: Color(red: 0.18, green: 0.18, blue: 0.22),
        cardText: Color.white,
        buttonBackground: Color(red: 0.22, green: 0.22, blue: 0.28),
        buttonText: Color.white,
        accent: Color(red: 0.4, green: 0.6, blue: 1.0),
        exprBackground: Color(red: 0.15, green: 0.15, blue: 0.18),
        exprText: Color.white,
        secondaryText: Color(white: 0.6)
    ),
    AppTheme(
        name: "Ocean",
        background: Color(red: 0.05, green: 0.15, blue: 0.3),
        cardBackground: Color(red: 0.08, green: 0.22, blue: 0.42),
        cardText: Color.white,
        buttonBackground: Color(red: 0.1, green: 0.28, blue: 0.5),
        buttonText: Color.white,
        accent: Color(red: 0.3, green: 0.85, blue: 0.85),
        exprBackground: Color(red: 0.06, green: 0.18, blue: 0.36),
        exprText: Color.white,
        secondaryText: Color(red: 0.5, green: 0.75, blue: 0.9)
    ),
    AppTheme(
        name: "Forest",
        background: Color(red: 0.08, green: 0.18, blue: 0.1),
        cardBackground: Color(red: 0.12, green: 0.25, blue: 0.14),
        cardText: Color.white,
        buttonBackground: Color(red: 0.15, green: 0.3, blue: 0.18),
        buttonText: Color.white,
        accent: Color(red: 0.4, green: 0.9, blue: 0.5),
        exprBackground: Color(red: 0.1, green: 0.2, blue: 0.12),
        exprText: Color.white,
        secondaryText: Color(red: 0.5, green: 0.8, blue: 0.55)
    ),
    AppTheme(
        name: "Sakura",
        background: Color(red: 1.0, green: 0.94, blue: 0.96),
        cardBackground: Color(red: 1.0, green: 0.85, blue: 0.9),
        cardText: Color(red: 0.5, green: 0.1, blue: 0.2),
        buttonBackground: Color(red: 0.98, green: 0.78, blue: 0.86),
        buttonText: Color(red: 0.5, green: 0.1, blue: 0.2),
        accent: Color(red: 0.9, green: 0.3, blue: 0.5),
        exprBackground: Color(red: 1.0, green: 0.9, blue: 0.93),
        exprText: Color(red: 0.5, green: 0.1, blue: 0.2),
        secondaryText: Color(red: 0.7, green: 0.4, blue: 0.5)
    ),
]

// MARK: - Model

struct CardItem: Identifiable {
    let id: Int
    let value: Int
    let display: String
    let suit: String
    let isRed: Bool
}

enum ExprToken {
    case number(value: Int, display: String, cardId: Int)
    case op(String)
    case leftParen
    case rightParen
    
    var label: String {
        switch self {
        case .number(_, let d, _): return d
        case .op(let s): return s
        case .leftParen: return "("
        case .rightParen: return ")"
        }
    }
}

// MARK: - Game Logic

func generateCards() -> [CardItem] {
    let suits = ["♠", "♥", "♦", "♣"]
    let redSuits = ["♥", "♦"]
    var cards: [CardItem] = []
    for i in 0..<4 {
        let raw = Int.random(in: 1...10) // hanya angka 1-10
        let val = raw
        let display = "\(raw)" // tampilkan angka langsung
        let suit = suits.randomElement()!
        cards.append(CardItem(id: i, value: val, display: display, suit: suit, isRed: redSuits.contains(suit)))
    }
    return cards
}

func hasSolution(_ nums: [Int]) -> Bool {
    findSolution(nums) != nil
}

func permutations(_ arr: [Double]) -> [[Double]] {
    guard arr.count > 1 else { return [arr] }
    var result: [[Double]] = []
    for (i, v) in arr.enumerated() {
        var rest = arr
        rest.remove(at: i)
        for p in permutations(rest) {
            result.append([v] + p)
        }
    }
    return result
}

func applyOp(_ a: Double, _ op: String, _ b: Double) -> Double? {
    switch op {
    case "+": return a + b
    case "-": return a - b
    case "*": return a * b
    case "/": return b == 0 ? nil : a / b
    default: return nil
    }
}

func findSolution(_ nums: [Int]) -> String? {
    let doubles = nums.map { Double($0) }
    let ops = ["+", "-", "*", "/"]
    for p in permutations(doubles) {
        let (a, b, c, d) = (p[0], p[1], p[2], p[3])
        let ns = [a, b, c, d]
        let ni = nums // for display label matching
        _ = ni
        for o1 in ops { for o2 in ops { for o3 in ops {
            // 5 bracket structures
            let structures: [(()->(Double?))] = [
                { if let r1 = applyOp(a,o1,b), let r2 = applyOp(r1,o2,c) { return applyOp(r2,o3,d) }; return nil },
                { if let r1 = applyOp(b,o2,c), let r2 = applyOp(a,o1,r1) { return applyOp(r2,o3,d) }; return nil },
                { if let r1 = applyOp(a,o1,b), let r2 = applyOp(c,o3,d) { return applyOp(r1,o2,r2) }; return nil },
                { if let r1 = applyOp(b,o2,c), let r2 = applyOp(r1,o3,d) { return applyOp(a,o1,r2) }; return nil },
                { if let r1 = applyOp(c,o3,d), let r2 = applyOp(b,o2,r1) { return applyOp(a,o1,r2) }; return nil },
            ]
            let labels = [o1,o2,o3].map { $0 == "*" ? "×" : $0 == "/" ? "÷" : $0 }
            let pDisplay = ns.map { $0 == 1 ? "A" : $0 == 10 ? "10" : "\(Int($0))" }
            let exprStrs = [
                "((\(pDisplay[0])\(labels[0])\(pDisplay[1]))\(labels[1])\(pDisplay[2]))\(labels[2])\(pDisplay[3])",
                "(\(pDisplay[0])\(labels[0])(\(pDisplay[1])\(labels[1])\(pDisplay[2])))\(labels[2])\(pDisplay[3])",
                "(\(pDisplay[0])\(labels[0])\(pDisplay[1]))\(labels[1])(\(pDisplay[2])\(labels[2])\(pDisplay[3]))",
                "\(pDisplay[0])\(labels[0])((\(pDisplay[1])\(labels[1])\(pDisplay[2]))\(labels[2])\(pDisplay[3]))",
                "\(pDisplay[0])\(labels[0])(\(pDisplay[1])\(labels[1])(\(pDisplay[2])\(labels[2])\(pDisplay[3])))",
            ]
            for (idx, struct_) in structures.enumerated() {
                if let result = struct_(), abs(result - 24) < 1e-9 {
                    return exprStrs[idx]
                }
            }
        }}}
    }
    return nil
}

func evaluateExpression(_ tokens: [ExprToken]) -> Double? {
    // Build string dengan simbol standar
    var expr = ""
    for token in tokens {
        switch token {
        case .number(let v, _, _): expr += "\(v)"
        case .op(let s):
            // Ganti simbol ke yang bisa dipahami NSExpression
            let mapped = s == "×" ? "*" : s == "÷" ? "/" : s == "−" ? "-" : s
            expr += mapped
        case .leftParen: expr += "("
        case .rightParen: expr += ")"
        }
    }
    
    // Evaluasi menggunakan NSExpression
    let nsExpression = NSExpression(format: expr)
    if let result = nsExpression.expressionValue(with: nil, context: nil) as? NSNumber {
        return result.doubleValue
    } else {
        return nil
    }
}

// MARK: - Views

struct CardView: View {
    let card: CardItem
    let isUsed: Bool
    let theme: AppTheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isUsed ? theme.cardBackground.opacity(0.4) : theme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isUsed ? theme.accent.opacity(0.3) : theme.accent.opacity(0.6), lineWidth: isUsed ? 1 : 2)
                    )
                    .frame(width: 72, height: 100)
                
                VStack(spacing: 0) {
                    Text(card.suit)
                        .font(.system(size: 12))
                        .padding(6)
                    Spacer()
                }
                
                Text(card.display)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(card.isRed ? Color(red: 0.85, green: 0.2, blue: 0.2) : theme.cardText)
                    .frame(width: 72, height: 100)
            }
            .opacity(isUsed ? 0.4 : 1.0)
        }
        .disabled(isUsed)
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isUsed ? 1.0 : 1.0)
        .animation(.spring(response: 0.2), value: isUsed)
    }
}

struct TokenChip: View {
    let token: ExprToken
    let theme: AppTheme
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(token.label)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(theme.exprText)
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(theme.secondaryText)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(theme.exprBackground)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(theme.secondaryText.opacity(0.3), lineWidth: 0.5))
    }
}

// MARK: - Main View

struct ContentView: View {
    @State private var cards: [CardItem] = []
    @State private var tokens: [ExprToken] = []
    @State private var usedCardIds: Set<Int> = []
    @State private var statusMessage: String = ""
    @State private var statusType: StatusType = .neutral
    @State private var score: Int = 0
    @State private var streak: Int = 0
    @State private var showHint: Bool = false
    @State private var hintText: String = ""
    @State private var showThemePicker: Bool = false
    @State private var selectedThemeIndex: Int = 0
    @State private var showResult: Bool = false
    
    enum StatusType { case neutral, success, error }
    
    var theme: AppTheme { themes[selectedThemeIndex] }
    
    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("24 Point")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(theme.cardText)
                        Text("make 24 from 4 cards")
                            .font(.system(size: 12))
                            .foregroundColor(theme.secondaryText)
                    }
                    Spacer()
                    Button(action: { showThemePicker.toggle() }) {
                        Image(systemName: "paintpalette.fill")
                            .font(.system(size: 20))
                            .foregroundColor(theme.accent)
                            .padding(8)
                            .background(theme.buttonBackground)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                // Theme picker
                if showThemePicker {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(themes.indices, id: \.self) { i in
                                Button(action: { selectedThemeIndex = i; showThemePicker = false }) {
                                    Text(themes[i].name)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(i == selectedThemeIndex ? themes[i].accent : themes[i].cardText)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(themes[i].cardBackground)
                                        .cornerRadius(20)
                                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(i == selectedThemeIndex ? themes[i].accent : Color.clear, lineWidth: 2))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 12)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                // Score bar
                HStack(spacing: 20) {
                    VStack(spacing: 2) {
                        Text("\(score)").font(.system(size: 20, weight: .semibold)).foregroundColor(theme.accent)
                        Text("score").font(.system(size: 11)).foregroundColor(theme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(theme.cardBackground.opacity(0.5))
                    .cornerRadius(12)
                    
                    VStack(spacing: 2) {
                        Text("\(streak)").font(.system(size: 20, weight: .semibold)).foregroundColor(theme.accent)
                        Text("streak").font(.system(size: 11)).foregroundColor(theme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(theme.cardBackground.opacity(0.5))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                
                // Cards
                HStack(spacing: 12) {
                    ForEach(cards) { card in
                        CardView(card: card, isUsed: usedCardIds.contains(card.id), theme: theme) {
                            addCard(card)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // Expression area
                VStack(alignment: .leading, spacing: 8) {
                    Text("expression")
                        .font(.system(size: 12))
                        .foregroundColor(theme.secondaryText)
                        .padding(.horizontal, 20)
                    
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(theme.exprBackground)
                            .frame(minHeight: 60)
                        
                        if tokens.isEmpty {
                            Text("tap cards and operators below...")
                                .font(.system(size: 14))
                                .foregroundColor(theme.secondaryText.opacity(0.6))
                                .padding(12)
                        } else {
                            FlowLayout(spacing: 6) {
                                ForEach(tokens.indices, id: \.self) { i in
                                    TokenChip(token: tokens[i], theme: theme) {
                                        removeToken(at: i)
                                    }
                                }
                            }
                            .padding(10)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 14)
                
                // Operator buttons
                HStack(spacing: 10) {
                    ForEach(["+", "−", "×", "÷", "(", ")"], id: \.self) { op in
                        Button(action: { addOp(op) }) {
                            Text(op)
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(theme.buttonText)
                                .frame(width: 48, height: 48)
                                .background(theme.buttonBackground)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(theme.accent.opacity(0.3), lineWidth: 0.5))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                
                // Status message
                if !statusMessage.isEmpty {
                    Text(statusMessage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(statusType == .success ? Color.green : statusType == .error ? Color(red: 0.9, green: 0.3, blue: 0.2) : theme.secondaryText)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 6)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: statusMessage)
                }
                
                // Hint
                if showHint && !hintText.isEmpty {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                        Text(hintText)
                            .font(.system(size: 13))
                            .foregroundColor(theme.cardText)
                    }
                    .padding(10)
                    .background(theme.buttonBackground)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 6)
                }
                
                // Action buttons
                HStack(spacing: 10) {
                    ActionButton(label: "Check", icon: "checkmark.circle", color: theme.accent, theme: theme) { checkAnswer() }
                    ActionButton(label: "Clear", icon: "arrow.uturn.backward", color: theme.secondaryText, theme: theme) { clearExpr() }
                    ActionButton(label: "Hint", icon: "lightbulb", color: Color.yellow, theme: theme) { toggleHint() }
                    ActionButton(label: "New", icon: "shuffle", color: theme.accent, theme: theme) { newGame() }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                Spacer()
            }
        }
        .onAppear { newGame() }
        .animation(.easeInOut(duration: 0.25), value: showThemePicker)
    }
    
    // MARK: - Actions
    
    func addCard(_ card: CardItem) {
        guard !usedCardIds.contains(card.id) else { return }
        usedCardIds.insert(card.id)
        tokens.append(.number(value: card.value, display: card.display, cardId: card.id))
        statusMessage = ""
    }
    
    func addOp(_ op: String) {
        switch op {
        case "(": tokens.append(.leftParen)
        case ")": tokens.append(.rightParen)
        default: tokens.append(.op(op))
        }
        statusMessage = ""
    }
    
    func removeToken(at index: Int) {
        let tok = tokens[index]
        if case .number(_, _, let cardId) = tok {
            usedCardIds.remove(cardId)
        }
        tokens.remove(at: index)
        statusMessage = ""
    }
    
    func clearExpr() {
        tokens = []
        usedCardIds = []
        statusMessage = ""
        showHint = false
    }
    
    func checkAnswer() {
        let usedNums = tokens.compactMap { token -> Int? in
            if case .number(let v, _, _) = token { return v }
            return nil
        }
        let cardVals = cards.map { $0.value }.sorted()
        let usedVals = usedNums.sorted()
        
        guard usedVals.count == 4 && usedVals == cardVals else {
            statusMessage = "⚠️ Gunakan semua 4 kartu tepat 1x!"
            statusType = .error
            return
        }
        
        guard let result = evaluateExpression(tokens) else {
            statusMessage = "❌ Ekspresi tidak valid"
            statusType = .error
            return
        }
        
        if abs(result - 24) < 1e-9 {
            score += 1
            streak += 1
            statusMessage = "🎉 Benar! = 24"
            statusType = .success
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                newGame()
            }
        } else {
            streak = 0
            statusMessage = "= \(formatResult(result)), bukan 24. Coba lagi!"
            statusType = .error
        }
    }
    
    func formatResult(_ v: Double) -> String {
        if v.truncatingRemainder(dividingBy: 1) == 0 { return "\(Int(v))" }
        return String(format: "%.2f", v)
    }
    
    func toggleHint() {
        if showHint { showHint = false; return }
        let sol = findSolution(cards.map { $0.value })
        hintText = sol ?? "Tidak ada solusi untuk kartu ini 😅"
        showHint = true
    }
    
    func newGame() {
        var newCards: [CardItem]
        var tries = 0
        repeat {
            newCards = generateCards()
            tries += 1
        } while !hasSolution(newCards.map { $0.value }) && tries < 200
        cards = newCards
        tokens = []
        usedCardIds = []
        statusMessage = ""
        showHint = false
    }
}

// MARK: - Helper Views

struct ActionButton: View {
    let label: String
    let icon: String
    let color: Color
    let theme: AppTheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(label)
                    .font(.system(size: 11))
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(theme.buttonBackground)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.3), lineWidth: 0.5))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 { x = 0; y += rowHeight + spacing; rowHeight = 0 }
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        return CGSize(width: maxWidth, height: y + rowHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX { x = bounds.minX; y += rowHeight + spacing; rowHeight = 0 }
            view.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
