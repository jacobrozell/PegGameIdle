# System Spec — Test Plan & CI

## Layers
- **Domain unit tests** (`Tests/PegGameDomainTests`) — pure logic. Run with
  `swift test`. No simulator; CI/Linux-safe. This is the primary safety net.
- **App unit tests** (`Tests/Unit`, hosted target `PegGameIdleTests`) — exercise
  view-model logic: tap/drag interaction, jump scoring, Auto-Jumper isolation,
  upgrades, daily mode, reset. Run via `xcodebuild test` on a simulator; fast
  because they drive the model, not the UI.
- **UI smoke** (`Tests/UI`, target `PegGameIdleUITests`) — XCUITest: tab bar,
  play controls, settings sheet, onboarding skip, upgrade purchase. Runs in
  `PegGameIdleCI` on iPhone simulator in CI.

## What domain tests cover today
- Board: hole/peg counts, opening moves, legal/illegal/non-adjacent jumps, win
  & stuck detection, Codable round-trip.
- AutoPlayer: only-legal-moves invariant, play-to-completion, determinism under
  a seeded RNG, nil on finished board.
- EconomyEngine: reward math, prestige scaling, purchase + insufficient-funds
  error, cost growth, offline accrual (none without Auto-Jumper, rate-correct,
  capped), Codable round-trip.

## CI scheme
- `.github/workflows/ci.yml` (macos-14, pinned latest-stable Xcode): runs
  `swift test` (domain), then `xcodegen generate`, then `xcodebuild test` for the
  `PegGameIdleCI` scheme (app build + unit + UI smoke tests) on iPhone 16 simulator.

## Launch arguments (for deterministic UI runs)
- `-reset_state` — clear persisted progress before launch.
- `-disable_telemetry` — no analytics in tests (telemetry is off in 1.0 anyway).
- `-ui_test_show_onboarding` — force onboarding sheet on launch.
- `-ui_test_rich_state` — grant 10,000 Peg Points for upgrade UI tests.
- `-ui_test_offline_report` — inject welcome-back sheet on launch.

`-reset_state` and `-disable_telemetry` are honored in `AppDependencies.live()`:
the former wipes persisted progress before launch, the latter forces telemetry
off (which is already the 1.0 default). `PegGameIdleApp` uses `AppDependencies.live()`.

## Future (Phase 12)
Split UI targets (`*UISmoke`, `*UIFeatures`, `*UIAccessibility`,
`*UILocalization`, `*UILandscape`), nightly full matrix, in-memory test doubles
shared across suites.
