# Accessibility Reference — VoiceOver, Dynamic Type, Reduce Motion

Used by: uiux-agent, qa-agent

## VoiceOver Labels

Every interactive element must have an `accessibilityLabel`:

```swift
// Character card
CharacterDisplay(character: "あ")
    .accessibilityLabel("Hiragana A")
    .accessibilityValue("あ")
    .accessibilityHint("Tap to flip and hear pronunciation")

// Audio button
AudioButton(action: playSound)
    .accessibilityLabel("Play pronunciation")
    .accessibilityHint("Plays Japanese pronunciation of this character")

// Confidence badge
ConfidenceBadge(value: 0.92)
    .accessibilityLabel("Confidence 92 percent")

// Locked lesson card
LockedCard(level: "N4")
    .accessibilityLabel("N4 Lesson, locked")
    .accessibilityHint("Complete N5 exam to unlock")

// Scan button
Button("Scan") { startScan() }
    .accessibilityLabel("Scan character")
    .accessibilityHint("Takes a photo and detects the Japanese character")
```

## Dynamic Type

Never hardcode font sizes in views — always use AppTheme scale or relative sizes:

```swift
// CORRECT
Text(character)
    .font(.system(size: 60, weight: .bold, design: .serif))
    .dynamicTypeSize(.medium ... .accessibility3)

// WRONG
Text(character)
    .font(.system(size: 60))  // no Dynamic Type range
```

Test at: Settings → Accessibility → Display & Text Size → Larger Text

## Reduce Motion

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

// Flashcard flip
func flip() {
    if reduceMotion {
        isFlipped.toggle()  // instant switch, no animation
    } else {
        withAnimation(.easeInOut(duration: 0.3)) {
            rotation += 180
        }
    }
}

// Button press animation
.scaleEffect(isPressed ? 0.97 : 1.0)
.animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: isPressed)
```

## Focus Order

For VoiceOver, ensure logical reading order:
```swift
VStack {
    CharacterDisplay(character: char)        // read first
    Text(meaning)                            // read second
    AudioButton(action: play)               // read third
    ConfidenceBadge(value: confidence)      // read last
}
.accessibilityElement(children: .contain)
```

## Color & Non-Color Indicators

Never use color alone to convey information:

```swift
// CORRECT — color + icon + text
ConfidenceBadge(value: confidence) {
    HStack {
        Circle().fill(color)           // color
        Image(systemName: iconName)    // icon
        Text(percentText)              // text
    }
}

// WRONG — color only
Circle().fill(confidence > 0.8 ? .green : .red)
```

## Minimum Touch Target

All tappable elements must be at least 44×44pt:

```swift
AudioButton()
    .frame(minWidth: 44, minHeight: 44)

// Or use contentShape for non-button views
SomeView()
    .contentShape(Rectangle())
    .frame(minWidth: 44, minHeight: 44)
```

## Rules

- Every button and interactive element needs `accessibilityLabel`
- All animations must be disabled when `reduceMotion` is true
- Never convey state via color alone — always add icon or text
- All touch targets minimum 44×44pt
- Test VoiceOver by enabling it in Simulator: Hardware → Toggle Software Keyboard, then Cmd+F5
