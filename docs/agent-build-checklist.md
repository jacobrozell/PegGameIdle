# Agent Build Checklist — Peg Game Idle (0 → Ship)

Living document. The full domain-agnostic template (agent query template, prompt
library, phase detail) was provided at project kickoff; this copy tracks **our**
progress against it. Check boxes, add dates + commit hashes as phases complete.

**Owner decisions (locked for 1.0):**

| Decision | Value |
|----------|-------|
| App name / bundle ID | Peg Game Idle / `com.jacobrozell.peggameidle` |
| Min iOS | 17.0 (SwiftData-ready, `@Observable`) |
| Swift | 5.9 |
| Bundled locale (1.0) | `en` only |
| Telemetry | none in 1.0 (hooks deferred to Phase 14) |
| Tip/donate link | none for 1.0 (`AppLinks.tipJar = nil`) |
| Orientation | portrait on iPhone; all orientations on iPad |
| MVP scope | peg solitaire idle loop, upgrades, offline accrual, local persistence — polished UI on `plan/ui-overhaul` ahead of **1.0.0** tag |

## Source-of-truth hierarchy

governance/spec index → system specs → feature specs → `docs/feature-inventory.md`
(what ships today) → `docs/brainstorm.md` (maybe, not authoritative).

## 1.0 polish (in progress)

**Plan:** [`docs/ui-overhaul-plan.md`](ui-overhaul-plan.md) · **Branch:** `plan/ui-overhaul`

13 phases: design system → tab shell → feedback/haptics → board motion → onboarding →
designed sheets → achievements → upgrade polish → daily tab → prestige UX → launch splash →
a11y hardening → CI/release. Domain stays mostly unchanged; presentation layer rebuilt
using ScrollBloom patterns as reference. **No public release until `1.0.0` tag.**

## Architecture at a glance

```
App/         @main, AppDependencies (composition root)
Features/    SwiftUI + @Observable view models (Game, Upgrades)
DesignSystem/ Theme tokens (color, metrics, touch targets)
Data/        Repository protocols + UserDefaults / in-memory impls
Sources/PegGameDomain/  PURE logic — no SwiftUI, no persistence (SwiftPM package)
Tests/PegGameDomainTests/  domain unit tests (run via `swift test`, CI/Linux-safe)
Tests/UI/    XCUITest smoke
specs/, docs/  contracts + reality
```

Dependency rule: `Domain` imports nothing app-specific. Features depend on
`any GameStateRepository`, never concrete persistence.

---

## Progress log

| Phase | Completed | Commit | Notes |
|-------|-----------|--------|-------|
| 0 Repo & infra | 2026-06-20 | _initial_ | XcodeGen `project.yml`, layered folders, `.gitignore` (secrets + generated proj), asset catalog. SwiftLint/git-hooks/MCP config still open. |
| 1 Spec system | 2026-06-20 | _initial_ | `specs/` system + feature specs, brainstorm, feature-inventory. |
| 2 Design system & a11y foundations | 2026-06-20 | _initial_ | `Theme` tokens, 44pt targets, non-color cues, a11y labels/ids on board + upgrades. Contrast evidence + Dynamic Type audit open. |
| 3 Domain (test-first) | 2026-06-20 | _initial_ | Board rules, AutoPlayer, EconomyEngine — 25+ unit tests. |
| 4 Persistence | 2026-06-20 | _initial_ | Repository protocol + UserDefaults/in-memory impls. SwiftData migration deferred. |
| 5 App shell | 2026-06-20 | _initial_ | `@main`, AppDependencies, NavigationStack. Router/onboarding/flags open. |
| 6 First vertical slice | 2026-06-20 | _initial_ | entry → play board → earn → persist → offline reconcile. Integration test open. |
| 6b Prestige + polish | 2026-06-20 | _follow-up_ | Prestige loop (bank points → permanent multiplier), compact K/M/B formatting, `-reset_state`/`-disable_telemetry` launch args honored. +12 domain tests. |
| 6c Gameflow mechanics | 2026-06-20 | _follow-up_ | Specs: scoring + daily-puzzle. Completion scoring (rank multiplier + streak + auto-deal), Auto-Jumper on its own board, drag-to-jump + tap fallback, date-seeded Daily Puzzle feeding prestige. +18 domain tests. UI unverified (no toolchain). |
| 7 (partial) Adaptive layout | 2026-06-20 | _follow-up_ | iPad-landscape two-column vs stacked via `AdaptiveLayout` (idiom-based, +3 unit tests); offline "reserve full" cue. iPad side-by-side + Dynamic Type still need device QA. |
| 8 (partial) Settings | 2026-06-20 | _follow-up_ | Settings sheet (haptics/sound prefs, About links, reset-all-data with confirm), `AppLinks` registry (tip jar nil/hidden), `SettingsStore` protocol + impls. |
| 12 (partial) CI | 2026-06-20 | _follow-up_ | GitHub Actions (latest-stable Xcode): `swift test` (domain, 48 green) + xcodegen + `xcodebuild test` running hosted app unit tests (player interaction + drag) on a simulator. |
| 1.0 polish (partial) | 2026-06-20 | _in progress_ | Tab shell, design system, sheets/toasts, achievements, onboarding, haptics/sound, themes, undo/hint, board size upgrade, center peg bonus. 67 domain tests + CI green on simulator. |
| Remaining | | | Localization, a11y hardening, legal pages, release QA, **1.0.0 tag**. |

---

## Phase checklists (status)

### Phase 0 — Repo & agent infrastructure
- [x] 0.1 README = build/run entry
- [x] 0.2 XcodeGen `project.yml` single source for targets/schemes
- [x] 0.3 Layered folders (App/Features/Domain/Data/DesignSystem/Resources/Tests)
- [x] 0.4 Pinned deployment target, bundle ID, Swift version
- [x] 0.5 `.gitignore` for generated `.xcodeproj` + secrets
- [ ] 0.6 Git hooks to block committing secrets
- [ ] 0.7 `.cursor/mcp.json` (XcodeBuildMCP + simulator)
- [ ] 0.8 Cursor rules
- [ ] 0.9 SwiftLint + CI lint job
- [x] 0.10 CONTRIBUTING.md
- [ ] 0.11 Verify `xcodegen generate && xcodebuild build` — **needs macOS** (this agent ran on Linux; unverified)

### Phase 1 — Spec system
- [x] 1.1 Brainstorm marked non-authoritative
- [x] 1.2 System specs (architecture, accessibility, test plan)
- [x] 1.4 Feature specs end with Verification block
- [x] 1.5 `specs/README.md` index + `docs/feature-inventory.md`

### Phase 2 — Design system & a11y foundations
- [x] 2.1 Token layer (`Theme`)
- [x] 2.4 44×44pt touch targets
- [x] 2.5 Reusable controls ship a11y label/hint/identifier
- [x] 2.8 Supported orientations documented
- [ ] 2.2 Contrast evidence in `accessibility/`
- [ ] 2.3 Dynamic Type audit
- [ ] 2.7 Automated contrast/label contract tests

### Phase 3 — Domain (test-first)
- [x] 3.1 Domain types + rule engine, zero UI imports
- [x] 3.2 Typed errors at boundary (`PurchaseError`)
- [x] 3.4 Deterministic services (Board, AutoPlayer, EconomyEngine)
- [x] 3.5 Unit tests: happy path, validation, edges, codable round-trips

### Phase 4 — Persistence
- [x] 4.2 Repository protocols + impls behind them
- [x] 4.3 Single dependency container (`AppDependencies`)
- [x] 4.6 Features depend on `any GameStateRepository`
- [ ] 4.1 Versioned schema / migration (deferred — UserDefaults JSON for 1.0)

### Phase 5 — App shell
- [x] 5.1 `@main` + bootstrap
- [x] 5.2 Root navigation (4-tab `TabView` + `RootView`)
- [x] 5.5 Launch-argument handling (`-reset_state`, `-disable_telemetry`) in `AppDependencies.live()`
- [x] 5.4 Onboarding (first-run walkthrough)
- [ ] 5.3 Router for deep links
- [ ] 5.6 Release-surface gate module

### Phase 6 — First vertical slice
- [x] 6.1 Entry screen + ViewModel (offline "welcome back" banner)
- [x] 6.3 Primary interaction UI with a11y labels on every control
- [x] 6.4 Domain wired through ViewModel (no rules in `View.body`)
- [x] 6.5 Persist outcome
- [x] 6.7 UI test identifiers on critical controls
- [ ] 6.6 Integration test: slice + relaunch + restore (UI smoke present; full restore test open)

### Phase 7 — Shared chrome & adaptive layout (partial)
- [x] 7.4 Orientation: iPad-landscape two-column vs stacked elsewhere
- [x] 7.5 iPad predicate documented + unit-tested (`AdaptiveLayout`)
- [ ] 7.1 Shared headers/toolbars/empty-state components extracted
- [ ] 7.2 Non-color state indicators audit across all surfaces
- [ ] iPad side-by-side + Dynamic Type need device QA (no simulator here)

### Phases 8–18 — Remaining
Localization wrapper, a11y hardening, full CI matrix, release-surface gating,
legal pages, release QA, **1.0.0 tag**.

---

## Known gaps / honesty notes
- **Not built on macOS:** no `xcodegen`/`xcodebuild`/simulator in this
  environment. The app target (SwiftUI) is **unbuilt and unverified**. Domain
  unit tests are written to run via `swift test` but were not executed here.
- First action on a Mac: `swift test`, then `xcodegen generate` + build the
  `PegGameIdleCI` scheme. Fix any compile drift before feature work.
