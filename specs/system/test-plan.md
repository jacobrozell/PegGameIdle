# System Spec — Test Plan & CI

## Layers
- **Domain unit tests** (`Tests/PegGameDomainTests`) — pure logic. Run with
  `swift test`. No simulator; CI/Linux-safe. This is the primary safety net.
- **App unit tests** (`Tests/Unit`, hosted target `PegGameIdleTests`) — exercise
  view-model logic: tap/drag interaction, jump scoring, Auto-Jumper isolation,
  upgrades, daily mode, reset. Run via `xcodebuild test` on a simulator; fast
  because they drive the model, not the UI.
- **UI smoke** (`Tests/UI`) — XCUITest proving the core screen launches and key
  controls (by accessibility identifier) exist. Requires a simulator; not in PR
  CI yet (nightly candidate).

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
  `PegGameIdleCI` scheme (app build + hosted unit tests) on a discovered iPhone
  simulator.

## Launch arguments (for deterministic UI runs)
- `-reset_state` — clear persisted progress before launch.
- `-disable_telemetry` — no analytics in tests (telemetry is off in v1 anyway).
- (Future) `-enable_full_product_surface` — expose gated features for CI/dogfood.

`-reset_state` and `-disable_telemetry` are honored in `AppDependencies.live()`:
the former wipes persisted progress before launch, the latter forces telemetry
off (which is already the v1 default). `PegGameIdleApp` uses `AppDependencies.live()`.

## Future (Phase 12)
Split UI targets (`*UISmoke`, `*UIFeatures`, `*UIAccessibility`,
`*UILocalization`, `*UILandscape`), nightly full matrix, in-memory test doubles
shared across suites.
