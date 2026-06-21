# Stats & History Spec (1.0 — draft)

> **Status:** Draft on `plan/ui-overhaul`. Not authoritative until Phase 7 ships.

## Overview

Lifetime counters displayed in the **Awards tab** below achievements. Read-only; no separate History tab in 1.0.

## Displayed stats

| Stat | Source |
|------|--------|
| Total boards completed | `GameState` counter |
| Best rank achieved | Best (lowest) pegs remaining at board end |
| Lifetime Peg Points earned | Cumulative before spends (track separately from balance) |
| Prestige count | Existing prestige counter |
| Daily streak (current / best) | Existing daily fields |
| Achievements unlocked | `unlockedAchievements.count` / total |

## Domain

Extend `GameState` or add `StatsSnapshot` computed from persisted fields. Backfill lifetime earned from existing data where possible on migration.

## Future (post-1.0)

- Per-board run log (last 20 ranks)
- Game Center sync for daily fewest pegs

## Verification

| Field | Value |
|-------|-------|
| Target release | 1.0 |
| Last verified | — |
| Commit | — |
| Code | `Features/Awards/StatsSection.swift` |
