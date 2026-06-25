# Peg Game Idle

An iOS idle game built on **classic triangle peg solitaire** — jump pegs to earn **Peg Points**, let the **Auto-Jumper** earn while you're away, buy **upgrades**, **prestige** for permanent multipliers, and tackle a shared **Daily Puzzle** each day.

**Status:** v2 UI overhaul on `plan/ui-overhaul` · v1.0.0 (1) in repo · **No App Store release until the `1.0.0` tag**

Product behavior: [`specs/`](specs/README.md) · Shipped features: [`docs/feature-inventory.md`](docs/feature-inventory.md)

---

## What it does

- **Classic peg board** — 15-hole triangle with legal-move validation, undo, and hints
- **Idle economy** — Auto-Jumper, offline accrual with welcome-back report, board-size upgrade
- **Scoring** — rank multipliers, center-peg bonus, completion streaks
- **Daily Puzzle** — date-seeded board shared by all players; prestige-progress reward
- **Upgrades & prestige** — Peg Value, Auto-Jumper Speed, Offline Reserve; bank points for permanent multipliers
- **Awards tab** — achievements and lifetime stats
- **Polish** — 4 color themes, haptics/sound, onboarding, designed outcome sheets, iPad adaptive layout
- **Settings** — export/import save, reset all data, hosted legal links

Board sizes 6+ deferred to **v2.1** per [`docs/ui-overhaul-plan.md`](docs/ui-overhaul-plan.md).

---

## Requirements

- macOS with Xcode (iOS 17 SDK), Swift 5.9
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) — `brew install xcodegen`

| | |
|--|--|
| **Bundle** | `com.jacobrozell.peggameidle` |
| **Min iOS** | 17.0 |
| **Signing** | Automatic · team `7JT2JB89AV` |

---

## Run domain tests (no simulator)

The game logic is a standalone Swift package:

```bash
swift test
```

---

## Build & run the app

The `.xcodeproj` is generated and git-ignored:

```bash
xcodegen generate
open PegGameIdle.xcodeproj
```

CI scheme (build + unit + UI smoke):

```bash
xcodebuild test -scheme PegGameIdleCI \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

GitHub Actions runs domain tests + app build on every push/PR.

---

## App structure

```
App/                     @main + composition root (AppDependencies)
Features/                SwiftUI — Play · Upgrades · Daily · Awards tabs
DesignSystem/            Theme tokens, color themes, reusable components
Data/                    GameStateRepository + SettingsStore
Sources/PegGameDomain/   PURE game logic (SwiftPM package)
Tests/                   PegGameDomainTests (swift test) + UI smoke (XCUITest)
specs/ docs/             Behavior contracts + release checklists
```

---

## Architecture

Dependency flow: **Features → Domain ← Data**. Domain never imports SwiftUI. See [`specs/system/architecture.md`](specs/system/architecture.md).

---

## Documentation map

| Doc | Purpose |
|-----|---------|
| [`docs/ui-overhaul-plan.md`](docs/ui-overhaul-plan.md) | v2 phases (~12 steps) |
| [`docs/agent-build-checklist.md`](docs/agent-build-checklist.md) | Phase progress (0→ship) |
| [`docs/release/1.0.0-checklist.md`](docs/release/1.0.0-checklist.md) | Ship gate |
| [`docs/feature-inventory.md`](docs/feature-inventory.md) | What ships today |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | Conventions |

---

## Legal (hosted)

GitHub Pages from `/docs` on branch `main`:

- [Privacy](docs/privacy.html)
- [Support](docs/support.html)
- [Accessibility](docs/accessibility.html)
