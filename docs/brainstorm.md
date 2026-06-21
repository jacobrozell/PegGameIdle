# Brainstorm — Peg Game Idle (NON-AUTHORITATIVE)

> Per the build checklist, this file captures the raw idea. It is **not** a
> source of truth. Behavior is governed by `specs/`. Promote ideas to a feature
> spec only once the rules are locked.

## The pitch

An iOS idle game built on the classic **Cracker Barrel triangle peg game**
(15 holes, jump pegs to remove them, try to leave one peg) — but made
**interactive / idle**.

## The twist

Plain peg solitaire is a one-and-done puzzle. We layer an idle economy on top:

- **Every peg you jump earns Peg Points** (the currency).
- An **Auto-Jumper** keeps playing boards on its own, earning Peg Points over
  time — including while you're away (offline progress, capped).
- **Upgrades** spend Peg Points to earn faster: higher peg value, faster
  Auto-Jumper, bigger offline reserve.
- The human still matters: playing by hand is faster and more skillful than the
  idle baseline, and a perfect solve (one peg left) is the bragging-rights goal.

## Gameflow mechanics — 1.0 direction (decisions locked 2026-06-20)

Still non-authoritative; promote to specs before building. These came out of a
brainstorm on making scoring reward skill and giving daily reasons to return.

### Locked decisions
1. **Scoring = skill multiplier, no penalty.** You always keep the per-jump
   points you earned. Finishing a board grants a *completion multiplier* based
   on pegs remaining — sloppy boards just forgo the bonus, they never subtract
   currency.
2. **Input = drag-to-jump + tap fallback.** Drag a peg over a neighbor into the
   empty hole (tactile path); keep tap-peg-then-tap-hole for VoiceOver / Switch
   Control. Both call the same domain logic. Required to keep the WCAG gate.
3. **Daily puzzle rewards prestige progress** (not a new currency). A daily
   solve accelerates long-term prestige rather than paying spendable Peg Points.

### Board lifecycle
- **Auto-deal:** when no legal moves remain, show a short end-of-board tally
  (pegs left → rank → payout), then deal a fresh board automatically.
- Brand-neutral ranks in app: Expert (1 peg), Sharp (2), Fair (3), Rough (4+).

| Pegs left | Rank (app) | Board payout |
|-----------|------------|--------------|
| 1 | Expert | ×5 |
| 2 | Sharp | ×3 |
| 3 | Fair | ×2 |
| 4 | Rough | ×1.25 |
| 5+ | — | ×1 (jump points only) |

- **Streak/combo (optional layer):** consecutive finishes with ≤2 pegs left
  build a temporary multiplier that decays on a bad board. Gives skilled manual
  play a ceiling the greedy Auto-Jumper can't reach.

### Manual vs Auto-Jumper
- Auto-Jumper = the floor: greedy AI, ~×1, no streak. Keeps idle income flowing.
- Manual play = the ceiling: completion multipliers + streak.
- **Open:** should the Auto-Jumper run its *own* board so it doesn't consume the
  board you're mid-solve on? (Today it shares the human board.)

### Daily puzzle
- **Seeded by date** (`yyyy-MM-dd` → deterministic board); same for everyone
  that day. Variant options: fixed non-standard empty hole, larger board, or a
  pre-cleared "finish this" layout.
- **Reward:** accelerates prestige progress (per locked decision #3). Design
  options to pick from when specced:
  - grant bonus lifetime-jumps toward the `√` prestige formula, or
  - grant fractional prestige points directly, or
  - a temporary post-daily prestige-gain multiplier.
- **Streak:** miss a day → reset. Unlimited retries; credit best result, lock
  the streak on the first qualifying solve.
- Works fully offline; Game Center "fewest pegs" leaderboards layer on later
  since the board is deterministic.

### Backlog spice (post-1.0)
- Special pegs (golden = bonus, locked = must clear last).
- Board-size tiers as upgrades.
- "Leave the center peg" challenge objectives.

## Backlog ideas (post-1.0)

- Larger board tiers (size 6, 7…) as an upgrade — `BoardLayout(size:)` supports
  it; daily puzzle stays classic 15-hole for 1.0.
- Cosmetic peg skins, haptics, sound.
- Game Center leaderboards for fewest pegs remaining.

