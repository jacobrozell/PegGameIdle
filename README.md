# Peg Game Idle

An iOS idle game built on the classic **Cracker Barrel triangle peg game** — but
interactive: every peg you jump earns **Peg Points**, an **Auto-Jumper** keeps
earning while you're away, and **upgrades** make the loop spin faster.

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
# or: xcodebuild build -scheme PegGameIdleCI \
#       -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Project layout
```
App/          @main + composition root (AppDependencies)
Features/     SwiftUI screens + @Observable view models
DesignSystem/ Theme tokens (color, metrics, 44pt targets)
Data/         GameStateRepository protocol + impls
Sources/PegGameDomain/   PURE game logic (no SwiftUI) — the SwiftPM package
Tests/        PegGameDomainTests (swift test) + UI smoke (XCUITest)
specs/ docs/  behavior contracts + reality + build checklist
```

## Status
Early scaffold: domain layer + first vertical slice (play board → earn → persist
→ offline reconcile). See
[`docs/agent-build-checklist.md`](docs/agent-build-checklist.md) for the phase
progress log and known gaps.

> ⚠️ The SwiftUI app target has **not yet been built** — the scaffold was
> authored in a Linux environment without an Xcode toolchain. First step on a
> Mac: `swift test`, then `xcodegen generate` and build the CI scheme; fix any
> compile drift before adding features.
