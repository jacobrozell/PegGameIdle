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
Two input paths, same underlying domain logic:

1. **Drag-to-jump (primary, tactile):** press a peg and drag toward the empty
   hole you want to land in. Legal landing holes highlight on pick-up; on
   release the drag vector is matched to the best legal jump (by direction) and
   performed. A drag that matches no legal jump springs back — no penalty.
2. **Tap-select (fallback, accessible):** tap a peg to **select** it (legal
   landing holes highlight: green + down-arrow glyph, a non-color cue); tap a
   highlighted hole to **jump**; tap the selected peg again to deselect. This
   path is fully operable by VoiceOver and Switch Control, which cannot perform
   drags — required by the accessibility gate.

**Board end is automatic:** when no legal move remains the run ends, pays its
completion bonus, and a fresh board is dealt (see `scoring.md`). A manual **New
Board** control is still available.

## Economy hook
Each jump (manual or auto) awards `pegValue × prestigeMultiplier` Peg Points and
increments `totalPegsJumped`. End-of-board completion bonuses and streaks are
specced in `scoring.md`. See also `idle-economy.md`.

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
