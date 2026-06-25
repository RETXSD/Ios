# Design Reference — Japanese Neubrutalism System

Used by: uiux-agent

## Design Intent

Neubrutalism structure (hard borders, flat shadows, bold type) dengan Japanese color palette (torii red, sumi ink, washi white, tatami cream, kinkaku gold). Zero gradients, zero blur, zero rounded softness — only flat, bold, intentional.

## Color Tokens — AppTheme.swift

```swift
extension Color {
    static let toriiRed    = Color(hex: "#C62828")  // primary accent, CTA, active tab
    static let sakuraBlush = Color(hex: "#FFEBEE")  // hover bg, soft fill
    static let sumiInk     = Color(hex: "#1A1A2E")  // all borders, primary text
    static let washiWhite  = Color(hex: "#FDFAF5")  // card surface, input bg
    static let tatamiCream = Color(hex: "#F5EFE0")  // app background
    static let kinkakuGold = Color(hex: "#C9962A")  // XP, achievement, level-up
    static let goldSoft    = Color(hex: "#FFF8E1")  // gold soft background
}
```

## Shadow Tokens

```swift
extension View {
    // Cards, inputs — offset shadow
    func shadowCard() -> some View {
        self.shadow(color: Color.sumiInk, radius: 0, x: 4, y: 4)
    }

    // Buttons — bottom drop shadow
    func shadowButton() -> some View {
        self.shadow(color: Color.sumiInk, radius: 0, x: 0, y: 5)
    }

    // Card hover state
    func shadowCardHover() -> some View {
        self.shadow(color: Color.sumiInk, radius: 0, x: 6, y: 6)
    }
}
```

Never use `radius > 0` in any shadow. Flat offset only.

## Border Rules

```swift
// All cards and inputs
.border(Color.sumiInk, width: 2)

// Or via overlay for rounded corners
.overlay(
    RoundedRectangle(cornerRadius: 7)
        .stroke(Color.sumiInk, lineWidth: 2)
)
```

## Border Radius Tokens

```swift
enum AppRadius {
    static let card: CGFloat = 7       // cards, inputs, badges
    static let button: CGFloat = 999   // buttons, pills, tabs
    static let modal: CGFloat = 16     // bottom sheets, modals
}
```

## Button Styles

```swift
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.washiWhite)
            .padding(.vertical, 10)
            .padding(.horizontal, 22)
            .background(Color.toriiRed)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.sumiInk, lineWidth: 2))
            .shadowButton()
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .offset(y: configuration.isPressed ? 3 : 0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.washiWhite)
            .padding(.vertical, 10)
            .padding(.horizontal, 22)
            .background(Color.sumiInk)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.sumiInk, lineWidth: 2))
            .shadowButton()
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .offset(y: configuration.isPressed ? 3 : 0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct GoldButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.sumiInk)
            .padding(.vertical, 10)
            .padding(.horizontal, 22)
            .background(Color.kinkakuGold)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.sumiInk, lineWidth: 2))
            .shadowButton()
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .offset(y: configuration.isPressed ? 3 : 0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
```

## Card Style

```swift
struct AppCard<Content: View>: View {
    let content: () -> Content

    var body: some View {
        content()
            .padding(16)
            .background(Color.washiWhite)
            .cornerRadius(AppRadius.card)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.card)
                    .stroke(Color.sumiInk, lineWidth: 2)
            )
            .shadowCard()
    }
}
```

## Badge Style

```swift
struct AppBadge: View {
    let text: String
    let style: BadgeStyle

    enum BadgeStyle {
        case red, ink, soft, gold, cream
    }

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 2)
            .background(bgColor)
            .foregroundColor(fgColor)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(borderColor, lineWidth: 2))
    }
}
```

## Progress Bar

```swift
struct ProgressBar: View {
    let value: Double  // 0.0 – 1.0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 999)
                    .fill(Color.tatamiCream)
                    .overlay(
                        RoundedRectangle(cornerRadius: 999)
                            .stroke(Color.sumiInk, lineWidth: 2)
                    )
                RoundedRectangle(cornerRadius: 999)
                    .fill(Color.toriiRed)
                    .frame(width: geo.size.width * value)
            }
        }
        .frame(height: 10)
        .shadowCard()
    }
}
```

## Confidence Badge Colors

```swift
var confidenceColor: Color {
    switch confidence {
    case 0.8...: return .green       // high — good stroke
    case 0.5..<0.8: return .kinkakuGold  // mid — needs practice
    default: return .toriiRed            // low — try again
    }
}
```

## Typography

```swift
extension Font {
    static let appLabel   = Font.system(size: 9,  weight: .bold)
    static let appCaption = Font.system(size: 11, weight: .regular)
    static let appBody    = Font.system(size: 14, weight: .regular)
    static let appTitle   = Font.system(size: 18, weight: .bold)
    static let appMetric  = Font.system(size: 24, weight: .bold)
    static let appKanji   = Font.custom("HiraMinProN-W3", size: 60)
}
```

## Anti-Patterns — NEVER DO

- No gradient fills anywhere
- No shadow with `radius > 0`
- No rounded corners above 16px (except buttons/badges at 999px)
- No hardcoded hex colors outside AppTheme.swift
- No lime/green as primary color — toriiRed only
- No white background for app root — always tatamiCream
