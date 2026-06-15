# 🏋️ Fitness App — Design System
*Inspired by Energia Vital / Academia Social Media Kit*

---

## Brand Identity

| Property | Value |
|---|---|
| **Style** | Dark Athletic / High-Energy |
| **Mood** | Powerful, Motivating, Premium |
| **Platform** | iOS (SwiftUI) |

---

## Color Palette

### Primary Colors
| Name | Hex | Usage |
|---|---|---|
| **Neon Lime** | `#C6F135` | CTA buttons, highlights, active states |
| **Deep Black** | `#0A0A0A` | App background |
| **Surface Dark** | `#141414` | Card backgrounds |
| **Surface Mid** | `#1E1E1E` | Input fields, secondary cards |

### Text Colors
| Name | Hex | Usage |
|---|---|---|
| **White Primary** | `#FFFFFF` | Headings, primary labels |
| **White Secondary** | `#FFFFFFCC` | Body text, subtitles |
| **White Tertiary** | `#FFFFFF66` | Captions, placeholder |

### Semantic Colors
| Name | Hex | Usage |
|---|---|---|
| **Success** | `#C6F135` | Completed workouts |
| **Warning** | `#FFB800` | Warnings, streaks |
| **Error** | `#FF4D4D` | Errors, missed goals |
| **Info** | `#4DA6FF` | Info badges |

---

## Typography

### Font Stack
```
Display: "Bebas Neue"     → Bold headings, hero text
Body:    "DM Sans"        → Body, labels, UI text
Mono:    "JetBrains Mono" → Stats, numbers, timers
```

### Type Scale (iOS Points)
| Token | Size | Weight | Line Height | Usage |
|---|---|---|---|---|
| `hero` | 48pt | Black 900 | 1.0 | App hero / splash |
| `display` | 36pt | Bold 700 | 1.1 | Section titles |
| `title1` | 28pt | Bold 700 | 1.2 | Screen titles |
| `title2` | 22pt | SemiBold 600 | 1.3 | Card titles |
| `title3` | 18pt | SemiBold 600 | 1.3 | Sub-section |
| `body` | 16pt | Regular 400 | 1.5 | Body copy |
| `callout` | 15pt | Medium 500 | 1.4 | Callouts |
| `caption` | 12pt | Regular 400 | 1.4 | Labels, captions |
| `stat` | 32pt | Bold mono | 1.0 | Numbers / stats |

---

## Spacing System

Base unit: **4pt**

| Token | Value | Usage |
|---|---|---|
| `xs` | 4pt | Icon gaps |
| `sm` | 8pt | Internal padding |
| `md` | 16pt | Standard padding |
| `lg` | 24pt | Section gaps |
| `xl` | 32pt | Screen padding |
| `2xl` | 48pt | Hero sections |
| `3xl` | 64pt | Major separators |

---

## Border Radius

| Token | Value | Usage |
|---|---|---|
| `none` | 0 | Full-bleed images |
| `sm` | 8pt | Tags, badges |
| `md` | 12pt | Input fields |
| `lg` | 16pt | Cards |
| `xl` | 24pt | Bottom sheets, modals |
| `pill` | 999pt | Buttons, chips |
| `circle` | 50% | Avatars, icons |

---

## Component Library

### Buttons

#### Primary CTA
```
Background:    #C6F135 (Neon Lime)
Text:          #0A0A0A (Black)
Font:          DM Sans SemiBold 16pt
Height:        52pt
Border Radius: pill (26pt)
Padding:       0 24pt
State hover:   scale(0.97) + brightness(1.1)
```

#### Secondary
```
Background:    #1E1E1E
Text:          #FFFFFF
Border:        1pt solid #FFFFFF22
Height:        52pt
Border Radius: pill
```

#### Ghost / Outline
```
Background:    transparent
Text:          #C6F135
Border:        1.5pt solid #C6F135
Height:        44pt
Border Radius: pill
```

---

### Cards

#### Workout Card
```
Background:    #141414
Border Radius: 16pt
Padding:       16pt
Shadow:        0 8pt 32pt rgba(0,0,0,0.5)
Accent bar:    3pt left border, #C6F135
```

#### Plan / Price Card
```
Background:    #141414
Border Radius: 20pt
Padding:       20pt 16pt
Active state:  border 1.5pt solid #C6F135
               glow: 0 0 24pt rgba(198,241,53,0.2)
```

#### Stats Card
```
Background:    #1E1E1E
Border Radius: 12pt
Padding:       12pt 16pt
Number:        Mono Bold 32pt, #C6F135
Label:         DM Sans 12pt, #FFFFFF66
```

---

### Navigation

#### Tab Bar
```
Background:    #0F0F0F with blur
Border top:    0.5pt solid #FFFFFF15
Icon size:     24pt
Active icon:   #C6F135
Inactive icon: #FFFFFF44
Label:         DM Sans 10pt
Height:        83pt (with home indicator)
```

#### Navigation Bar
```
Background:    #0A0A0A (translucent blur)
Title:         DM Sans SemiBold 17pt, white
Back button:   #C6F135
Height:        44pt
```

---

### Form Elements

#### Text Input
```
Background:    #1E1E1E
Border:        1pt solid #FFFFFF15
Border Radius: 12pt
Padding:       14pt 16pt
Height:        52pt
Text:          DM Sans 16pt white
Placeholder:   #FFFFFF44
Focus border:  #C6F135
```

---

### Badges & Tags
```
Background:    rgba(198, 241, 53, 0.15)
Text:          #C6F135
Border:        1pt solid rgba(198,241,53,0.3)
Border Radius: pill
Padding:       4pt 10pt
Font:          DM Sans Medium 12pt
```

---

### Progress / Metrics

#### Progress Bar
```
Track:      #1E1E1E, height 6pt, radius pill
Fill:       linear-gradient(90deg, #C6F135, #A0D020)
Glow:       0 0 8pt rgba(198,241,53,0.4)
```

#### Circular Ring (Workout ring)
```
Track:      #1E1E1E
Fill:       #C6F135
Width:      8pt stroke
Glow:       #C6F135 with 0.3 opacity blur
```

---

## Iconography

- **Style**: Outlined, 2pt stroke weight
- **Size**: 24pt standard, 20pt small, 28pt large
- **Color**: Inherit from context (white or neon)
- **Library**: SF Symbols (iOS native) — preferred
- **Fallback**: Phosphor Icons

---

## Motion & Animation

| Type | Duration | Easing | Usage |
|---|---|---|---|
| Micro | 150ms | easeOut | Tap feedback |
| Standard | 250ms | spring(0.5) | State transitions |
| Modal | 350ms | spring(0.6) | Sheet presentation |
| Hero | 500ms | easeInOut | Page transitions |
| Celebration | 600ms | spring(0.8) | Achievement unlock |

### Key Principles
- Button press: `scaleEffect(0.96)` on tap
- Card appear: slide up + fade in (staggered)
- Numbers: count-up animation on load
- Progress rings: stroke draw animation on appear

---

## Imagery Guidelines

- **Photos**: Dark-toned, high contrast gym photography
- **Overlay**: `multiply` blend with dark background
- **Tint**: Subtle lime green diagonal accent shapes
- **Avatars**: Circular crop, dark border ring
- **Diagonal motifs**: `rotate(-8deg)` accent shapes in `#C6F135`

---

## Pricing Plans (Reference)

| Plan | Price | Color |
|---|---|---|
| Plano Básico | R$69/mês | `#FFFFFF` label |
| **Plano Premium** | R$199/mês | `#C6F135` (featured) |
| Plano Fitness | R$99/mês | `#FFFFFF` label |

---

## Accessibility

| Check | Requirement |
|---|---|
| Contrast (text on dark) | ≥ 4.5:1 |
| Contrast (large text) | ≥ 3:1 |
| Neon on black (#C6F135 / #0A0A0A) | ✅ 9.8:1 |
| Touch targets | ≥ 44×44pt |
| Dynamic Type | Support up to XXL |
| Haptics | Use UIImpactFeedbackGenerator |

---

## Naming Convention (SwiftUI)

```swift
// Colors
Color("NeonLime")       // #C6F135
Color("SurfaceDark")    // #141414
Color("SurfaceMid")     // #1E1E1E

// Styles
.font(.system(.title2, design: .default).weight(.semibold))

// Components
WorkoutCard
PlanCard
StatBadge
PrimaryButton
GhostButton
ProgressRing
```

---

*Design System v1.0 — Energia Vital Fitness App*
