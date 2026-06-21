# Feature Inventory — what ships *today*

> Reality, not aspiration. Specs describe behavior; this table describes the
> build. Update when a feature's status changes. **No App Store release until
> the `1.0.0` tag.**

| Feature | Status | Spec | Code |
|---------|--------|------|------|
| Classic 15-hole peg board (rules, legal moves, win/stuck detection) | ✅ shipped | `specs/features/peg-board.md` | `Sources/PegGameDomain/Board.swift` |
| Manual play earning Peg Points (drag-to-jump + tap fallback) | ✅ shipped | `specs/features/peg-board.md` | `Features/Game/` |
| Undo + hint (move stack, greedy auto-player hint) | ✅ shipped | — | `GameViewModel`, `BoardHint.swift` |
| Board size upgrade (sizes 5–8 on main board) | ✅ shipped | — | `Upgrade.boardSize`, `BoardLayout` |
| Center peg completion bonus (×1.5 when last peg on center) | ✅ shipped | `specs/features/scoring.md` | `EconomyEngine.completeBoard` |
| Completion scoring (rank multiplier, streak, auto-deal) | ✅ shipped | `specs/features/scoring.md` | `BoardRank.swift`, `EconomyEngine.completeBoard` |
| Daily Puzzle (date-seeded, prestige-progress reward, streak) | ✅ shipped | `specs/features/daily-puzzle.md` | `DailyPuzzle.swift`, `EconomyEngine.completeDaily` |
| Auto-Jumper (foreground idle play, own board) | ✅ shipped | `specs/features/idle-economy.md` | `GameViewModel.tickAutoJumper` |
| Offline accrual + "welcome back" report (capped) | ✅ shipped | `specs/features/idle-economy.md` | `EconomyEngine.reconcileOffline` |
| Upgrades: Peg Value, Auto-Jumper Speed, Offline Reserve, Board Size | ✅ shipped | `specs/features/idle-economy.md` | `Upgrade.swift`, `UpgradesSection.swift` |
| Local persistence (UserDefaults) | ✅ shipped | `specs/system/architecture.md` | `Data/GameStateRepository.swift` |
| 4-tab shell (Play · Upgrades · Daily · Awards) | ✅ shipped | `specs/system/app-shell.md` | `Features/Shell/RootView.swift` |
| Designed outcome sheets + toast feedback | ✅ shipped | `specs/system/app-shell.md` | `Features/Shared/` |
| Achievements + lifetime stats (Awards tab) | ✅ shipped | `specs/features/achievements.md` | `AchievementEngine`, `AwardsView` |
| Onboarding walkthrough (first run) | ✅ shipped | `specs/features/onboarding.md` | `Features/Onboarding/` |
| Haptics + sound (settings toggles) | ✅ shipped | — | `HapticEngine`, `SoundEngine`, `SettingsStore` |
| Color themes (Slate, Forest, Ocean, Sunset) | ✅ shipped | — | `AppColorTheme.swift`, `ThemePickerSection` |
| Prestige UX (meter, celebration sheet) | ✅ shipped | `specs/features/idle-economy.md` | `PrestigeSheet`, `PrestigeMeter` |
| Launch splash + ambient particles | ✅ shipped | — | `LaunchSplashView`, `AmbientParticlesView` |
| Adaptive layout (iPad-landscape two-column) + offline reserve-full cue | ✅ shipped | `specs/system/accessibility.md` | `AdaptiveLayout.swift`, `GameView.swift` |
| Compact number formatting (K/M/B) | ✅ shipped | `specs/features/idle-economy.md` | `NumberFormatting.swift` |
| Prestige (bank points → permanent multiplier, resets progress) | ✅ shipped | `specs/features/idle-economy.md` | `EconomyEngine.prestige`, `PrestigeRow` |
| Reset-state / disable-telemetry launch args | ✅ shipped | `specs/system/test-plan.md` | `App/AppDependencies.swift` |
| Settings screen (haptics/sound, theme, links, reset all data) | ✅ shipped | — | `Features/Settings/`, `SettingsStore.swift` |
| AppLinks registry (privacy/support/accessibility, tip jar hidden) | ✅ shipped | — | `Support/AppLinks.swift` |
| CI (domain tests + app build on push) | ✅ shipped | `specs/system/test-plan.md` | `.github/workflows/ci.yml` |
| Game Center leaderboards (fewest pegs) | ⛔ planned | backlog | daily board is deterministic; ready to layer on |
| Legal HTML pages + GitHub Pages hosting | ✅ shipped | — | `docs/privacy.html`, `docs/support.html`, `docs/accessibility.html` |
| Localization (multi-locale) | 🟡 partial | — | `Localizable.xcstrings` scaffold; tab bar + settings wired |
| Telemetry / analytics | ⛔ planned (1.0 = none) | — | — |
| iCloud sync | ⛔ planned | backlog | export/import only for 1.0 |

Legend: ✅ shipped · 🟡 partial (engine present, not surfaced) · ⛔ planned
