# Specs Index

Authoritative behavior contracts for Peg Game Idle. Code follows specs; when
they disagree, the spec wins (open a PR to change the spec first).

## System specs
- [`system/architecture.md`](system/architecture.md) — layers, dependency rules, persistence.
- [`system/accessibility.md`](system/accessibility.md) — WCAG 2.1 AA gate, per-screen tracker.
- [`system/test-plan.md`](system/test-plan.md) — test layers, CI scheme, launch args.

## Feature specs
- [`features/peg-board.md`](features/peg-board.md) — board rules, drag + tap input.
- [`features/idle-economy.md`](features/idle-economy.md) — currency, Auto-Jumper, upgrades, offline, prestige.
- [`features/scoring.md`](features/scoring.md) — board lifecycle, ranks, completion bonus, streak.
- [`features/daily-puzzle.md`](features/daily-puzzle.md) — date-seeded daily board, prestige reward.

Each feature spec ends with a **Verification** block (target release, last
verified date, commit, primary code paths). Non-authoritative ideas live in
[`../docs/brainstorm.md`](../docs/brainstorm.md).
