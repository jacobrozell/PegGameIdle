# Feature Spec — Daily Puzzle

A once-per-day seeded board that gives a reason to return. Promoted from
`docs/brainstorm.md` (decisions locked 2026-06-20).

## Reward principle (locked)
The daily puzzle **accelerates prestige progress** rather than paying spendable
currency. Implementation: completing it grants **bonus "prestige jumps"** that
feed the same `√` prestige formula as lifetime jumps, without inflating the
visible Auto-Jumper/manual jump counts or the spendable Peg Point balance.

## Board generation
- **Deterministic from the date.** `DailyPuzzle.seed(for:)` derives a `UInt64`
  seed from the UTC day number (`floor(timeIntervalSince1970 / 86400)`); the same
  day yields the same board for everyone.
- `DailyPuzzle.board(for:)` builds a classic 15-hole board with the single empty
  hole chosen pseudo-randomly from the seed (variant board sizes/shapes are
  backlog).
- `DailyPuzzle.dayNumber(for:)` is the streak/identity key.

## Completion & reward
`EconomyEngine.completeDaily(pegsLeft:on:state:) -> (GameState, DailyResult)`:

- **Once per day:** if today's puzzle was already claimed (`lastDailyDay ==
  today`), returns unchanged with `alreadyClaimed = true`. Unlimited *retries*
  are allowed; only the first qualifying claim counts.
- **Streak:** continues (`dailyStreak + 1`) when the previous claim was
  yesterday; otherwise resets to 1.
- **Prestige reward (bonus prestige jumps):**
  ```
  base   = 100 × completionMultiplier(pegsLeft)   // rank-scaled
  streak = 1 + 0.1 × (dailyStreak − 1)
  award  = base × streak
  dailyPrestigeJumps += award
  ```
- `pendingPrestige` is computed from `totalPegsJumped + dailyPrestigeJumps`, so a
  daily solve moves the player toward their next prestige point.

`DailyResult`: `{ dayNumber, rank, dailyStreak, prestigeJumpsAwarded,
alreadyClaimed }` — drives the daily summary UI.

## State (added to `GameState`)
- `dailyStreak: Int`
- `lastDailyDay: Int?` (UTC day number of last claim)
- `dailyPrestigeJumps: Double`

All decode-tolerant (older saves default them).

## Out of scope (v1)
- Game Center leaderboards (the board is deterministic, so this layers on later).
- Variant board sizes/shapes; "finish this" pre-cleared layouts.

---

### Verification
- Target release: v1.1
- Last verified: 2026-06-20 (spec authored; implementation follows this commit)
- Commit: _this branch_
- Primary code paths: `Sources/PegGameDomain/DailyPuzzle.swift`,
  `Sources/PegGameDomain/Economy/EconomyEngine.swift` (`completeDaily`),
  `Features/Daily/`
- Tests: `Tests/PegGameDomainTests/DailyPuzzleTests.swift`
