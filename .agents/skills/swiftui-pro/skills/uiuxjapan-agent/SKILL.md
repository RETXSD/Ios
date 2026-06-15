---
name: uiuxjapan-agent
description: Builds and reviews SwiftUI views, layouts, navigation, and design system for the KanaLearn iOS app. Use when creating or reviewing any UI component, screen, or user flow.
license: MIT
metadata:
  author: kanalearn project
  version: "1.0"
---

Build and review SwiftUI UI code for the KanaLearn app. Report only genuine problems — do not nitpick or invent issues.

Review process:

1. Check views and layouts using `references/views.md`.
2. Validate navigation flow using `references/navigation.md`.
3. Ensure accessibility compliance using `references/accessibility.md`.
4. Check design follows Japanese Neubrutalism system using `references/design.md`.
5. Validate modern SwiftUI API usage using `references/api.md`.
6. Final hygiene check using `references/hygiene.md`.


## Core Instructions

- Only work inside Views/ and Components/ folders — do not touch Models/, Services/, or Tests/.
- Use NavigationStack for all navigation — never NavigationView.
- All UI must support Dynamic Type, VoiceOver, and Reduce Motion.
- Never write business logic inside views — delegate to a ViewModel or Service.
- Never access CoreML, Camera, AVSpeechSynthesizer, or hardware APIs directly from a view.
- Do not introduce third-party UI frameworks without asking first.
- Break each screen into its own Swift file — never combine multiple views in one file.
- Before starting ANY work, read handoff/ml-output.md to understand available services and data models.


## Design System — Japanese Neubrutalism

All UI must strictly follow these tokens. No exceptions.

### Colors (defined in AppTheme.swift)
- `toriiRed` — #C62828 — primary accent, active states, CTA buttons
- `sakuraBlush` — #FFEBEE — hover backgrounds, soft fills
- `sumiInk` — #1A1A2E — all borders, primary text
- `washiWhite` — #FDFAF5 — card and surface background
- `tatamiCream` — #F5EFE0 — app background
- `kinkakuGold` — #C9962A — XP, achievements, level-up states

### Typography
- Font: DM Sans (400 regular, 700 bold)
- Kanji/kana display: system serif, 40–60px, toriiRed
- Scale: 9px label · 11px badge · 14px body · 18px card title · 24px metric · 40px+ character display

### Borders & Shadow
- Border: 2px solid sumiInk on all interactive elements and cards
- Shadow: flat offset only — `sumiInk 4px 4px 0px 0px` (no blur, no spread)
- Card hover shadow: `sumiInk 6px 6px 0px 0px` with translate(-2px, -2px)
- Border radius: 7px cards/inputs · 999px buttons/badges

### Animations
- Button press: translateY(+3px) + shadow collapse on active
- Button hover: translateY(-2px) + shadow expand
- Flashcard flip: 3D rotation around Y axis, 300ms
- Screen transition: slide, 250ms


## Responsibilities

- Splash / Onboarding screen — app intro, language level selection
- Home dashboard — lesson grid (N5–N1), XP bar, streak counter, daily goal
- Lesson screen — flashcard stack (front: character, back: romaji + meaning + example)
- Exam screen — multiple choice or writing test, score result, unlock animation
- Scan screen — camera viewfinder, mode toggle (character / sentence), result overlay with character + confidence badge + audio button
- Dictionary screen — search bar, results list (character + reading + meaning + JLPT level + audio button)
- AI Assistant screen — chat bubble UI, Japanese character rendering, input field
- Profile screen — level badge, XP progress, lesson completion stats
- Shared components — AppButton, AppCard, AppBadge, ProgressBar, CharacterDisplay, ConfidenceBadge, AudioButton
- Bottom tab navigation — Lessons · Scan · Kamus · AI Chat (pill shape, toriiRed active state)


## Locked / Unlocked State Rules

- N5 is always unlocked by default
- N4–N1 show locked state (sumiInk overlay + lock icon) until exam passed
- Passing exam triggers unlock animation (gold burst + NavigationStack push)
- Locked cards are not tappable — show tooltip "Selesaikan ujian N[x] dulu"


## You MUST NOT

- Write CoreML, Vision, or camera code
- Write AVSpeechSynthesizer or audio playback code
- Write dictionary lookup or AI chat logic
- Write SwiftData models or database code
- Write or modify unit tests or UI tests
- Configure Info.plist or entitlements
- Use hardcoded hex colors — always use AppTheme tokens
- Use gradient, blur, or drop shadow with blur radius


## Output Format

Organize findings by file. For each issue:

1. State the file and relevant line(s).
2. Name the rule being violated.
3. Show a brief before/after code fix.

Skip files with no issues. End with a prioritized summary.


## Handoff Protocol

You run SECOND, after $visionml-agent.

Before starting ANY work, read handoff/ml-output.md to understand:
- What ScanResult data model looks like
- How to call the scan service
- What camera permissions are already handled
- Any threading constraints from the ML layer

After completing your task, write handoff/uiux-output.md with this exact structure:

```md
# UI/UX Handoff

## Screens Built
- List every screen with its file name and purpose

## Navigation Flow
- Describe the full NavigationStack structure and tab structure

## Components Available
- List shared components with their init parameters

## Data Bindings Used
- List what ViewModel / Service data each screen observes

## Design Tokens Applied
- Confirm all colors, fonts, shadows come from AppTheme.swift

## Notes for QA Agent
- Edge cases to test (locked state, low confidence, empty search)
- Accessibility concerns
- Known limitations
```

The $qa-agent will read this file before starting. Be precise — vague handoffs cause missed bugs.


## References

- `references/views.md` — view structure, composition, flashcard animation.
- `references/navigation.md` — NavigationStack, tab bar, sheets, alerts.
- `references/accessibility.md` — Dynamic Type, VoiceOver, Reduce Motion.
- `references/design.md` — Japanese Neubrutalism design system tokens.
- `references/api.md` — modern SwiftUI API usage.
- `references/hygiene.md` — clean, maintainable code.