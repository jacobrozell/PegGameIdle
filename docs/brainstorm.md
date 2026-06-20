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

## Backlog ideas (not in v1)

- Prestige: reset for a permanent multiplier (`prestigeMultiplier` already in
  the domain model, not yet surfaced).
- Larger board tiers (size 6, 7…) as an upgrade — `BoardLayout(size:)` supports
  it; UI is classic-only for v1.
- Combo bonuses for efficient solves.
- Daily challenges / seeded boards.
- Cosmetic peg skins, haptics, sound.
- Game Center leaderboards for fewest pegs remaining.
