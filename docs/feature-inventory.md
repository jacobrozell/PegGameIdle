# Feature Inventory — what ships *today*

> Reality, not aspiration. Specs describe behavior; this table describes the
> build. Update when a feature's status changes.

| Feature | Status | Spec | Code |
|---------|--------|------|------|
| Classic 15-hole peg board (rules, legal moves, win/stuck detection) | ✅ shipped | `specs/features/peg-board.md` | `Sources/PegGameDomain/Board.swift` |
| Manual play (select peg → jump) earning Peg Points | ✅ shipped | `specs/features/peg-board.md` | `Features/Game/` |
| Auto-Jumper (foreground idle play) | ✅ shipped | `specs/features/idle-economy.md` | `GameViewModel.tickAutoJumper` |
| Offline accrual + "welcome back" report (capped) | ✅ shipped | `specs/features/idle-economy.md` | `EconomyEngine.reconcileOffline` |
| Upgrades: Peg Value, Auto-Jumper Speed, Offline Reserve | ✅ shipped | `specs/features/idle-economy.md` | `Upgrade.swift`, `UpgradesSection.swift` |
| Local persistence (UserDefaults) | ✅ shipped | `specs/system/architecture.md` | `Data/GameStateRepository.swift` |
| Compact number formatting (K/M/B) | ✅ shipped | `specs/features/idle-economy.md` | `Sources/PegGameDomain/NumberFormatting.swift` |
| Prestige (bank points → permanent multiplier, resets progress) | ✅ shipped | `specs/features/idle-economy.md` | `EconomyEngine.prestige`, `PrestigeRow` |
| Reset-state / disable-telemetry launch args | ✅ shipped | `specs/system/test-plan.md` | `App/AppDependencies.swift` |
| Larger board tiers (size 6+) | 🟡 partial | backlog | `BoardLayout(size:)` supports; UI classic-only |
| Settings / AppLinks / legal pages | ⛔ planned | — | — |
| Localization (multi-locale) | ⛔ planned | — | en strings inline |
| Telemetry / analytics | ⛔ planned (v1 = none) | — | — |
| Haptics / sound / cosmetics | ⛔ planned | — | — |

Legend: ✅ shipped · 🟡 partial (engine present, not surfaced) · ⛔ planned
