# System Spec — Test Plan & CI

## Layers
- **Domain unit tests** (`Tests/PegGameDomainTests`) — pure logic. Run with
  `swift test`. No simulator; CI/Linux-safe. This is the primary safety net.
- **UI smoke** (`Tests/UI`) — XCUITest proving the core screen launches and key
  controls (by accessibility identifier) exist. Requires a simulator.

## What domain tests cover today
- Board: hole/peg counts, opening moves, legal/illegal/non-adjacent jumps, win
  & stuck detection, Codable round-trip.
- AutoPlayer: only-legal-moves invariant, play-to-completion, determinism under
  a seeded RNG, nil on finished board.
- EconomyEngine: reward math, prestige scaling, purchase + insufficient-funds
  error, cost growth, offline accrual (none without Auto-Jumper, rate-correct,
  capped), Codable round-trip.

## CI scheme
- `PegGameIdleCI` builds the app + runs UI smoke (minutes-scale).
- Domain tests run as a separate, faster `swift test` job.

## Launch arguments (for deterministic UI runs)
- `-reset_state` — clear persisted progress before launch.
- `-disable_telemetry` — no analytics in tests (telemetry is off in v1 anyway).
- (Future) `-enable_full_product_surface` — expose gated features for CI/dogfood.

> **Note:** `-reset_state` / `-disable_telemetry` are referenced by the UI smoke
> test but not yet honored in `AppDependencies`/`PegGameIdleApp`. Wiring them is
> the first follow-up so the UI smoke is truly deterministic.

## Future (Phase 12)
Split UI targets (`*UISmoke`, `*UIFeatures`, `*UIAccessibility`,
`*UILocalization`, `*UILandscape`), nightly full matrix, in-memory test doubles
shared across suites.
