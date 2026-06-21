# Achievements Spec (1.0 — draft)

> **Status:** Draft on `plan/ui-overhaul`. Not authoritative until Phase 7 ships.

## Overview

12–15 milestones reward long-term play. Each unlocked achievement grants **+1% permanent multiplier** (stacking; cap TBD in playtest, recommend +15% max).

## Unlock rules

- Evaluated on `GameEvent` after relevant state changes (board complete, upgrade buy, prestige, daily solve).
- Each achievement unlocks **once**; idempotent re-evaluation is safe.
- Unlock triggers toast + haptic + VoiceOver announcement.

## Catalog (initial)

| ID | Title | Trigger |
|----|-------|---------|
| `first_jump` | First Jump | First manual jump |
| `first_board` | Board Cleared | First board completed (no moves left) |
| `genius` | Genius | First finish with 1 peg remaining |
| `streak_3` | Three-Day Streak | Daily streak ≥ 3 |
| `streak_7` | Week Warrior | Daily streak ≥ 7 |
| `boards_10` | Regular | 10 boards completed |
| `boards_100` | Centurion | 100 boards completed |
| `upgrade_max` | Maxed Out | Any upgrade at max level |
| `prestige_1` | Fresh Start | First prestige |
| `prestige_5` | Veteran | Fifth prestige |
| `peg_points_1k` | Thousand Points | Lifetime Peg Points earned ≥ 1K |
| `peg_points_1m` | Millionaire | Lifetime Peg Points earned ≥ 1M |

Additional milestones may be added before ship; IDs are stable strings in `AchievementID`.

## Persistence

`GameState.unlockedAchievements: Set<AchievementID>`

## UI

- **Awards tab** — list all achievements; locked rows show `???` title until unlocked (or show title with locked icon — decide in Phase 7).
- Progress hints where countable (e.g. "87/100 boards").

## Domain

- `Sources/PegGameDomain/Achievement.swift` — catalog
- `Sources/PegGameDomain/AchievementEngine.swift` — pure evaluation

## Verification

| Field | Value |
|-------|-------|
| Target release | 1.0 |
| Last verified | — |
| Commit | — |
| Code | `AchievementEngine.swift`, `Features/Awards/` |
