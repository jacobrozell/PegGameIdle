# Feature Spec — Peg Board

## Summary
The classic Cracker Barrel triangle peg game: a triangular board, jump pegs to
remove them, aim to leave a single peg.

## Board geometry
- Triangle of `size` rows; row `r` has `r + 1` holes indexed `0...r`.
- Classic board = `size: 5` = 15 holes (`BoardLayout.classic`).
- Holes addressed by `Position(row:col:)`. `(0,0)` is the apex.

## Rules
- The board starts full except one empty hole (default apex `(0,0)`).
- A **legal jump**: a peg leaps in a straight line over an *adjacent* peg into
  the empty hole immediately beyond it; the jumped peg is removed.
- Six jump directions (triangular grid): left, right, up-left, up-right,
  down-left, down-right (`JumpDirection`).
- **Game over** when no legal jumps remain. **Solved** when exactly one peg
  remains (`isSolved`).

## Interaction (UI)
1. Tap a peg to **select** it; legal landing holes highlight (green + down-arrow
   glyph, non-color cue).
2. Tap a highlighted hole to **jump**. Tap the selected peg again to deselect.
   Tapping another peg re-selects.
3. **New Board** resets the board, keeping idle progress.

## Economy hook
Each jump (manual or auto) awards `pegValue × prestigeMultiplier` Peg Points and
increments `totalPegsJumped`. See `idle-economy.md`.

## Accessibility
- Each hole is a button with id `hole-{row}-{col}`, label reflecting state
  (Peg / Empty hole / Selected peg / Empty landing hole), and a hint.
- 44pt targets. Landing holes use a glyph, not color alone.

## Out of scope (v1)
- Board sizes other than classic (engine supports; UI does not).
- Undo/redo, hints, seeded daily boards.

---

### Verification
- Target release: v1.0
- Last verified: 2026-06-20 (code review; **not run** — no Swift toolchain in
  build environment)
- Commit: _initial scaffold_
- Primary code paths: `Sources/PegGameDomain/{Board,Move,BoardLayout,Position}.swift`,
  `Features/Game/{GameViewModel,BoardView,GameView}.swift`
- Tests: `Tests/PegGameDomainTests/BoardTests.swift`, `Tests/UI/GameUISmokeTests.swift`
