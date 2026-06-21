# System Spec — Architecture

## Layers & dependency rules

```
Features (SwiftUI + @Observable VMs)
   │  depends on
   ▼
Data (repository protocols)        Domain (pure logic, SwiftPM package)
   │  implemented by                    ▲
   ▼                                    │ used by Features & Data
Persistence (UserDefaults / SwiftData)──┘
```

- **Domain never imports SwiftUI or any persistence framework.** It is a
  standalone SwiftPM package (`Sources/PegGameDomain`) so it unit-tests on CI
  (including Linux) with `swift test` — no simulator required.
- **Features** hold UI and `@MainActor @Observable` view models. View models
  translate user intent into Domain calls; **no business rules in `View.body`**.
- **Data** exposes `protocol GameStateRepository`. Features depend on
  `any GameStateRepository`, never a concrete store.
- **Composition root** is `App/AppDependencies.swift`, constructed once in
  `@main` and injected into features.

## Project generation
- `project.yml` (XcodeGen) is the single source of truth for the app target,
  schemes, and build settings. The generated `.xcodeproj` is **git-ignored**.
- The domain package is referenced as a local SwiftPM dependency.

## Persistence (1.0)
- `GameState` is a `Codable` value type serialized as JSON in `UserDefaults`
  under `peggameidle.state.v1`.
- Rationale: state is tiny (a few numbers + upgrade levels). SwiftData with a
  versioned schema + migration is a Phase-4 follow-up if the schema grows
  (e.g. per-board history). The repository protocol makes that swap local.

## Idle time model
- **Foreground:** a 1 Hz timer calls `GameViewModel.tickAutoJumper(seconds:)`.
- **Offline:** on launch, `EconomyEngine.reconcileOffline(now:state:)` credits
  Auto-Jumper earnings for elapsed time since `lastSeen`, capped by the
  Offline Reserve upgrade. Time is **injected** (no hidden `Date()` in pure
  logic) for deterministic tests.

## Min platform
iOS 17.0, Swift 5.9. Uses `@Observable` (Observation) and modern SwiftUI.
