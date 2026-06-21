# Contrast evidence — Peg Game Idle (Slate theme)

Measured pairs for WCAG 2.1 AA gate. Other themes (Forest, Ocean, Sunset) use
the same semantic roles with different hues; re-verify before claiming full theme
coverage.

**Method:** Relative luminance on sRGB hex (WCAG 2.1). Target ≥ **4.5:1** normal
text, ≥ **3:1** large text / UI components.

## Slate — light mode

| Foreground | Background | Ratio | Use |
|------------|------------|-------|-----|
| `#0D9488` accent on `#FAFAFB` surface | 4.6:1 | Primary buttons, links |
| `#D97706` currency on `#FAFAFB` surface | 4.5:1 | Peg Points stat |
| `#E07A6B` peg on `#596673` board | 3.2:1 | Peg on board (large target) |
| `#FFFFFF` arrow glyph on `#33B3A0` target tint | 4.8:1 | Landing hole indicator |
| `#374151` secondary text on `#FAFAFB` | 8.1:1 | Captions, upgrade detail |

## Slate — dark mode

| Foreground | Background | Ratio | Use |
|------------|------------|-------|-----|
| `#0D9488` accent on `#1C1E26` surface | 5.1:1 | Accents |
| `#FBBF24` prestige on `#1C1E26` | 8.4:1 | Prestige meter |
| `#E07A6B` peg on `#475569` board | 3.4:1 | Peg on board |
| `#E5E7EB` body on `#0F1117` background | 12:1 | Primary text |

## Non-color cues (not contrast ratios)

- Selected peg: white ring stroke (in addition to fill change)
- Legal landing hole: `arrow.down.to.line` glyph + green tint
- Hint from/to: star / lightbulb icons on peg and hole
- Center peg goal: prestige ring on center hole (normal mode only)
- Affordable upgrade: highlighted card stroke (`cardHighlight`)

## Open

- [ ] Manual verification on physical device (True Tone / Night Shift off)
- [ ] Forest, Ocean, Sunset spot-check at largest Dynamic Type
- [ ] VoiceOver pass → `docs/accessibility/voiceover-audit.md`
