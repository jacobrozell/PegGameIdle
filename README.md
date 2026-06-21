# Peg Game Idle

An iOS idle game built on **classic triangle peg solitaire** — jump pegs to earn
**Peg Points**, let the **Auto-Jumper** earn while you're away, buy **upgrades**,
**prestige** for permanent multipliers, and tackle a shared **Daily Puzzle** each day.

This README is the build/run entry point. Product behavior lives in
[`specs/`](specs/README.md); what actually ships is in
[`docs/feature-inventory.md`](docs/feature-inventory.md).

## Requirements
- macOS with Xcode (iOS 17 SDK), Swift 5.9
- [XcodeGen](https://github.com/yonsson/XcodeGen) — `brew install xcodegen`

## Run the domain tests (no simulator needed)
The game logic is a standalone Swift package, so it tests anywhere Swift runs:

```bash
swift test
```

## Build & run the app
The `.xcodeproj` is generated and git-ignored. Generate it, then open:

```bash
xcodegen generate
open PegGameIdle.xcodeproj
# CI scheme (build + unit + UI smoke):
xcodebuild test -scheme PegGameIdleCI \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

## App structure
```
App/          @main + composition root (AppDependencies)
Features/     SwiftUI — Play · Upgrades · Daily · Awards tabs
DesignSystem/ Theme tokens, color themes, reusable components
Data/         GameStateRepository + SettingsStore
Sources/PegGameDomain/   PURE game logic (SwiftPM package)
Tests/        PegGameDomainTests (swift test) + UI smoke (XCUITest)
specs/ docs/  behavior contracts + release checklists
```

## Status
Pre-release polish on branch `plan/ui-overhaul`: tab shell, designed sheets,
achievements, onboarding, haptics/sound, four color themes, undo/hint, board size
upgrade, export/import. **No App Store release until the `1.0.0` tag.**

See [`docs/agent-build-checklist.md`](docs/agent-build-checklist.md) for phase
progress and [`docs/release/1.0.0-checklist.md`](docs/release/1.0.0-checklist.md)
for the ship gate.

Legal/support pages (GitHub Pages): [`docs/privacy.html`](docs/privacy.html),
[`docs/support.html`](docs/support.html), [`docs/accessibility.html`](docs/accessibility.html).
