# App Shell Spec (1.0 — draft)

> **Status:** Draft on `plan/ui-overhaul`. Not authoritative until Phase 2 ships.

## Structure

`RootView` hosts a 4-tab `TabView`:

| Tab | View | Tab ID |
|-----|------|--------|
| Play | `PlayView` | `tab.play` |
| Upgrades | `UpgradesView` | `tab.upgrades` |
| Daily | `DailyView` | `tab.daily` |
| Awards | `AwardsView` | `tab.awards` |

Settings opens as a **sheet** from the Play toolbar gear button (`settings.button`).

## Shared chrome

- **`CurrencyHeader`** — Peg Points, prestige multiplier, Auto-Jumper rate; present on all tabs (compact variant TBD).
- **`PegBackground`** — warm gradient behind board on Play tab; optional ambient particles (Settings).
- **`ToastView`** — transient messages; auto-dismiss ~2.5s; spring from top; respects Reduce Motion.

## Game loop

`RootView` runs a `Timer` at 1s interval calling `GameViewModel.tickAutoJumper(seconds: 1)`.

Scene phase: save on background; offline reconcile on active (existing `PegGameIdleApp` behavior).

## Sheets

| Sheet | Trigger | View |
|-------|---------|------|
| Onboarding | First launch (`!hasSeenOnboarding`) | `OnboardingView` |
| Settings | Gear tap | `SettingsView` |
| Welcome back | `offlineReport` set | `WelcomeBackSheet` |
| Board result | `boardResult` set | `BoardResultSheet` |
| Daily result | `dailyResult` set | `DailyResultSheet` |
| Prestige confirm | User taps Prestige | `PrestigeSheet` |

Gameplay outcomes **must not** use system `alert()`. Destructive reset in Settings may use `confirmationDialog`.

## First-run hints

- **Onboarding** — three-page sheet on first launch; existing saves with progress skip via migration.
- **Upgrades nudge** — toast after N boards with zero upgrades purchased (tune in playtest).

## UI test hooks

| Launch arg | Effect |
|------------|--------|
| `-reset_state` | Clean game state (existing) |
| `-ui_test_show_onboarding` | Force onboarding sheet |
| `-ui_test_offline_report` | Force welcome-back sheet |

See [`test-plan.md`](test-plan.md) for full launch-arg registry.

## Verification

| Field | Value |
|-------|-------|
| Target release | 1.0 |
| Last verified | — |
| Commit | — |
| Code | `Features/Shell/RootView.swift` (planned) |
