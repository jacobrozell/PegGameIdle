# System Spec — Accessibility (release gate)

Target: **WCAG 2.1 AA**. No launch with open critical failures on core flows.

## Principles baked into the design system
- **Touch targets ≥ 44×44 pt** (`Theme.Metrics.minTouchTarget`). Pegs and
  upgrade rows meet this.
- **Never color-only.** The selected peg gets a white ring; landing holes show
  an `arrow.down.to.line` glyph in addition to the green tint.
- **Drag has a non-drag equivalent.** Drag-to-jump is the tactile primary input,
  but the tap-select path (tap peg → tap landing hole) performs every jump and is
  fully operable by VoiceOver and Switch Control. Drag is layered as a
  `simultaneousGesture` so it never blocks the button's accessibility action.
- **Every control ships** `accessibilityLabel`, `accessibilityHint`, and
  `accessibilityIdentifier` (the latter doubles as the UI-test contract).
- **Dynamic Type:** use semantic text styles; avoid fixed font sizes in body
  copy. (Largest-size audit still open — see tracker.)

## Per-screen tracker

| Screen | VoiceOver | Dynamic Type (AXXXL) | Contrast (light/dark) | Orientation | Status |
|--------|-----------|----------------------|-----------------------|-------------|--------|
| Game (board + header + upgrades) | labels/hints/ids in code; **manual pass pending** | not audited | not measured | iPhone portrait; iPad portrait stacked; iPad landscape two-column (`AdaptiveLayout`, unit-tested) | 🟡 engineering pass only |

Legend: 🟡 code-level a11y present, manual verification outstanding.

## Identifier conventions (UI-test contract)
- Holes: `hole-{row}-{col}`
- Peg Points value: `peg-points-value`
- Status line: `status-line`
- New board: `new-board-button`
- Daily Puzzle: `daily-puzzle-button`
- Prestige: `prestige-button`
- Upgrade rows: `upgrade-{kind.rawValue}`

## Open items before claiming a11y in App Store
- [ ] Manual VoiceOver pass → dated doc in `accessibility/audits/`
- [ ] Largest Dynamic Type pass (header + upgrades must not clip)
- [ ] Contrast evidence (peg vs board wood; cost text vs background) light + dark
- [ ] Reduce Motion respected once animations are added
- [ ] Orientation matrix once iPad layout lands
