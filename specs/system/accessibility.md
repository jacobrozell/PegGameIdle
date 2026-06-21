# System Spec — Accessibility (release gate)

Target: **WCAG 2.1 AA**. No launch with open critical failures on core flows.

## Principles baked into the design system
- **Touch targets ≥ 44×44 pt** (`Theme.Metrics.minTouchTarget`). Pegs and
  upgrade rows meet this.
- **Never color-only.** Selected peg: white ring. Landing holes: `arrow.down.to.line`
  glyph + tint. Hints: star / lightbulb icons.
- **Drag has a non-drag equivalent.** Tap peg → tap landing hole; same domain path.
- **Every control ships** `accessibilityLabel`, `accessibilityHint`, and
  `accessibilityIdentifier` (UI-test contract in `Support/AccessibilityIdentifiers.swift`).
- **Dynamic Type:** semantic text styles; `ViewThatFits` on `CurrencyHeader`,
  `UpgradeRow`, `PrestigeMeter`, achievement rows.
- **Reduce Motion:** splash, particles, peg arcs/deal, toast slide, board pulse
  glyphs, prestige celebration respect `accessibilityReduceMotion` and Settings
  → Ambient motion.

## Per-screen tracker

| Screen | VoiceOver | Dynamic Type | Contrast | Orientation | Status |
|--------|-----------|--------------|----------|-------------|--------|
| Play (board + controls) | ids + labels in code; manual pass pending | `ViewThatFits` header/meter | Slate evidence in [`../../docs/accessibility/contrast-evidence.md`](../../docs/accessibility/contrast-evidence.md) | iPhone portrait; iPad side-by-side | 🟡 |
| Upgrades | row labels + buy buttons | action row wraps | same | portrait / iPad | 🟡 |
| Daily | calendar cells labeled | card stacks | same | portrait / iPad | 🟡 |
| Awards | locked/unlocked labels | achievement rows adapt | same | portrait / iPad | 🟡 |
| Settings | toggles + links | Form | same | sheet | 🟡 |
| Onboarding | combined page labels; Skip/Next ids | ScrollView + scaled emoji | same | sheet | 🟡 |

Legend: 🟡 engineering pass + partial evidence; manual VoiceOver audit still open.

## Identifier conventions (UI-test contract)
- Tabs: `tab-play`, `tab-upgrades`, `tab-daily`, `tab-awards`
- Holes: `hole-{row}-{col}`
- Peg Points value: `peg-points-value`
- Status line: `status-line`
- Undo / hint: `undo-button`, `hint-button`, `clear-hint-button`
- New board / daily exit: `new-board-button`
- Daily: `daily-play-button`, `daily-view-board-button`, `daily-practice-button`
- Prestige: `prestige-button`, `prestige-meter`
- Upgrade rows: `upgrade-{kind}`; buy: `upgrade-buy-{kind}-{levels}`
- Onboarding: `onboarding-skip`, `onboarding-next`, `onboarding-get-started`
- Settings: `settings-button`, `settings-haptics-toggle`, `settings-particles-toggle`

## Open items before App Store
- [ ] Manual VoiceOver pass → `docs/accessibility/voiceover-audit.md`
- [ ] Largest Dynamic Type device pass (iPhone SE + iPad)
- [ ] Forest / Ocean / Sunset contrast spot-check
- [ ] Hosted legal pages live on GitHub Pages

## Verification
- Target release: 1.0
- Last verified: 2026-06-20 (code + contrast doc for Slate)
- Primary code paths: `Features/Game/BoardView.swift`, `Features/Shell/RootView.swift`, `Support/DynamicTypeLayout.swift`
