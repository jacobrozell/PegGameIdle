# Feature Spec — Idle Economy

## Summary
The idle layer over peg solitaire: jumping pegs earns **Peg Points (PP)**, an
**Auto-Jumper** earns them passively (online and offline), and **upgrades** spend
PP to earn faster. This is what makes the puzzle an idle game.

## Currency & rewards
- Currency: `pegPoints` (Double — idle games use large numbers).
- Reward per jump = `pegValue × prestigeMultiplier`.
  - `pegValue = 1 + level(pegValue)` (base 1).
  - `prestigeMultiplier` defaults to 1 (prestige UI is backlog).
- `totalPegsJumped` tracks lifetime jumps (manual + auto).

## Auto-Jumper
- Rate (jumps/sec) = `0.5 × level(autoJumperSpeed)`; 0 at level 0.
- **Foreground:** a 1 Hz timer plays whole jumps via a deterministic greedy
  `AutoPlayer` on the live board; when the board ends the player starts a new one
  implicitly (next tick acts on whatever board is present — currently the human's
  board). Earnings credit immediately.
- **Offline:** on launch, `EconomyEngine.reconcileOffline(now:state:)` credits
  `rate × min(elapsed, cap)` jumps. Time is injected for testability.

## Upgrades (repeatable, geometric cost)

| Kind | Effect | Base cost | Growth |
|------|--------|-----------|--------|
| Peg Value | `+1` PP per jump per level | 25 | ×1.18 |
| Auto-Jumper Speed | `+0.5` jumps/sec per level | 100 | ×1.30 |
| Offline Reserve | `+2` h offline cap per level (base 2 h) | 250 | ×1.45 |

- Cost of next level = `base × growth^currentLevel`, rounded.
- Purchase throws `insufficientFunds` if `pegPoints < cost`.

## Offline "welcome back"
On return, if the Auto-Jumper earned anything, show a one-shot alert:
jumps cleared + PP banked. `wasCapped` is tracked (UI may surface "reserve full"
later). Dismiss credits nothing extra (already credited).

## Prestige
- **Pending points** = `floor(sqrt(totalPegsJumped / 500)) − prestigePointsClaimed`.
- Each banked point adds `0.1` to the permanent `prestigeMultiplier`
  (1 point → 1.1×, 2 → 1.2×, …), applied to every future reward.
- **Prestige** is offered (button + confirmation dialog) once ≥ 1 point is
  pending. It banks all pending points, then **resets** `pegPoints` and
  `upgradeLevels`. Lifetime `totalPegsJumped` persists so prestige value never
  goes backward.
- Pure logic: `EconomyEngine.pendingPrestige / canPrestige / projectedMultiplier
  / prestige`.

## Number formatting
Large values display compactly (`1.23K`, `2.5M`, `1B`) via
`NumberFormatting.compact` — pure and locale-independent for stable tests.

## Persistence
`GameState` (pegPoints, prestigeMultiplier, totalPegsJumped, upgradeLevels,
lastSeen) is saved on every economy mutation via `GameStateRepository`.

## Accessibility
- PP value: id `peg-points-value`, monospaced digits.
- Upgrade rows: id `upgrade-{kind}`, label includes name + cost; disabled +
  hinted when unaffordable.

## Open / backlog
- Auto-Jumper auto-resetting its own board independent of the human board.
- "Reserve full" surfacing when offline earnings are capped (`wasCapped`).

---

### Verification
- Target release: v1.0
- Last verified: 2026-06-20 (code review; tests **not run** — no Swift toolchain)
- Commit: _initial scaffold_
- Primary code paths: `Sources/PegGameDomain/Economy/*.swift`,
  `Features/Game/GameViewModel.swift`, `Features/Upgrades/UpgradesSection.swift`
- Tests: `Tests/PegGameDomainTests/{EconomyTests,AutoPlayerTests}.swift`
