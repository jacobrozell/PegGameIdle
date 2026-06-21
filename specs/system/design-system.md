# Design System Spec (1.0 — draft)

> **Status:** Draft on `plan/ui-overhaul`. Not authoritative until Phase 1 ships.

## Principles

1. **Warm wood identity** — peg solitaire tavern aesthetic; not a clone of ScrollBloom's garden theme.
2. **Dark-mode adaptive** — all semantic colors have light/dark variants; WCAG AA on intended backgrounds.
3. **Motion with respect** — `motionSafe(_:reduceMotion:)` returns `nil` when Reduce Motion is on.
4. **Touch targets** — minimum 44×44 pt (existing `Theme.Metrics.minTouchTarget`).

## Color tokens

| Token | Usage |
|-------|-------|
| `background` | Screen gradient base |
| `surface` | Card fill |
| `surfaceElevated` | Sheets, modals |
| `currency` | Peg Points values |
| `prestige` | Prestige multiplier, seeds |
| `accent` | CTAs, tab tint |
| `success` | Affordable upgrade highlight |
| `boardWood` | Board tray |
| `peg` / `pegSelected` / `pegTarget` | Board pieces |

Concrete RGB values live in `DesignSystem/Theme.swift` with contrast evidence in [`accessibility.md`](accessibility.md).

## Typography

| Style | Usage |
|-------|-------|
| `currencyLarge` | Header Peg Points (rounded, monospaced digits) |
| `statLabel` | Uppercase caption labels in stat tiles |
| `statValue` | Monospaced numeric stats |
| `sectionTitle` | Tab section headers |

## Spacing scale

4 · 8 · 12 · 16 · 24 · 32 pt — use consistently; no magic numbers in views.

## Components

| Component | File | Notes |
|-----------|------|-------|
| `Card` | `DesignSystem/Components/Card.swift` | Optional green/success stroke when highlighted |
| `StatTile` | `DesignSystem/Components/StatTile.swift` | Label + value column |
| `BrandedButton` | `DesignSystem/Components/BrandedButton.swift` | primary / secondary / destructive |
| `PegBackground` | `DesignSystem/Components/PegBackground.swift` | Play tab backdrop |

## Motion

| Interaction | Duration | Notes |
|-------------|----------|-------|
| Peg select | ~0.15s | Scale + ring |
| Peg jump | ~0.25s | Arc or slide |
| Board deal | ~0.4s stagger | New pegs appear |
| Toast | spring 0.3s | From top |
| Sheet rank reveal | spring 0.4s | Board result only |

Disable peg arc, particles, toast slide, and splash crossfade when Reduce Motion is enabled.

## Verification

| Field | Value |
|-------|-------|
| Target release | 1.0 |
| Last verified | — |
| Commit | — |
| Code | `DesignSystem/` |
