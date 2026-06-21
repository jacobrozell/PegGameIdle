# Onboarding Spec (1.0 — draft)

> **Status:** Draft on `plan/ui-overhaul`. Not authoritative until Phase 5 ships.

## Trigger

Show `OnboardingView` sheet when `GameState.hasSeenOnboarding == false`.

**Migration:** Existing saves with `totalBoardsCompleted > 0` → set `hasSeenOnboarding = true`. Brand-new saves → `false`.

## Content (3 pages)

1. **How to play** — Jump pegs over neighbors into empty holes; remove jumped pegs.
2. **Scoring** — Every jump earns Peg Points; fewer pegs left = bigger completion bonus (Genius = best).
3. **Idle loop** — Upgrades, Auto-Jumper, Daily Puzzle, Prestige overview.

## Presentation

- Sheet with `.medium, .large` detents (`.large` only at accessibility text sizes).
- Skip on every page; "Get started" on page 3 sets `hasSeenOnboarding = true`.
- Replay: Settings → Help → "How to play".

## UI test

Launch arg `-ui_test_show_onboarding` forces sheet regardless of save state.

## Verification

| Field | Value |
|-------|-------|
| Target release | 1.0 |
| Last verified | — |
| Commit | — |
| Code | `Features/Onboarding/OnboardingView.swift` |
