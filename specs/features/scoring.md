# Feature Spec — Board Scoring & Lifecycle

Governs how a board run starts, ends, and pays out. Promoted from
`docs/brainstorm.md` (decisions locked 2026-06-20).

## Design principle
**Reward skill; never punish.** The player keeps every per-jump point earned.
Finishing a board grants a *completion bonus* scaled by how few pegs remain. A
sloppy board simply forgoes the bonus — it never subtracts currency.

## Board lifecycle
1. A run plays on a full board minus one empty hole.
2. Each jump (manual) immediately awards `pegValue × prestigeMultiplier` Peg
   Points and increments lifetime `totalPegsJumped`. These points accumulate as
   the run's `boardEarnings`.
3. When no legal move remains, the run **ends**: compute the rank + completion
   bonus, award it, show a short tally, then **auto-deal** a fresh board.

## Ranks (Cracker Barrel flavor)

| Pegs left | Rank (`BoardRank`) | Completion multiplier |
|-----------|--------------------|-----------------------|
| 1 | Genius | 5.0 |
| 2 | Purty Smart | 3.0 |
| 3 | Just Plain Dumb | 2.0 |
| 4 | Eg-no-ra-moose | 1.25 |
| 5+ | Eg-no-ra-moose | 1.0 |

`BoardRank(pegsLeft:)` is a pure domain mapping.

## Completion bonus
At board end:

```
streakWorthy   = pegsLeft <= 2                         // genius / purty smart
streakCount    = streakWorthy ? streakCount + 1 : 0    // reset on a weak finish
streakMult     = 1 + 0.1 × streakCount                 // 1.0, 1.1, 1.2, …
bonus          = boardEarnings × (completionMult − 1) × streakMult
```

- At rank 5+ (`completionMult == 1`) the bonus is 0 regardless of streak — the
  forgone-bonus behavior.
- The streak gives skilled manual play a ceiling the greedy Auto-Jumper never
  reaches.
- `EconomyEngine.completeBoard(pegsLeft:boardEarnings:state:)` returns the new
  `GameState` plus a `BoardResult` (rank, multipliers, streak, bonus) for the UI
  tally.

## Manual vs Auto-Jumper
- **Manual play** earns per-jump points *and* completion bonuses + streak — the
  ceiling.
- **Auto-Jumper** runs on its **own** board (not the human's, so it never
  consumes a run you're mid-solve), earns per-jump points only at ×1, no
  completion bonus, no streak — the floor. Its board auto-deals on finish.

## Out of scope (1.0)
- Real-time streak *decay* (we reset on a weak finish instead).
- Special pegs, board-size tiers, custom objectives.

---

### Verification
- Target release: 1.0
- Last verified: 2026-06-20 (spec authored; implementation follows this commit)
- Commit: _this branch_
- Primary code paths: `Sources/PegGameDomain/BoardRank.swift`,
  `Sources/PegGameDomain/Economy/EconomyEngine.swift` (`completeBoard`),
  `Features/Game/GameViewModel.swift`
- Tests: `Tests/PegGameDomainTests/CompletionScoringTests.swift`
