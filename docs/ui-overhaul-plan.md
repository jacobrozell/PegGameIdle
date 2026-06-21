# UI Overhaul Plan — Peg Game Idle v2

> **Branch:** `plan/ui-overhaul` (cut from `main` after v1 merge)  
> **Status:** Draft — planning only, not authoritative until phases ship  
> **Inspired by:** ScrollBloom (BloomScroll) production patterns — tab shell, designed sheets, toast feedback, achievements, onboarding, responsive layout  
> **Goal:** Transform Peg Game Idle from a **functional v1 vertical slice** into a **polished, feature-rich idle product** without rewriting domain logic.

---

## Executive summary

Peg Game Idle has a strong **domain layer** (board rules, economy, daily puzzle, prestige, scoring) and a **minimal UI layer** (single scroll screen, system alerts, 22-line theme, zero motion). ScrollBloom proves the opposite shape works well: modest game complexity, **heavy product polish**.

This plan overhauls **presentation, navigation, meta-progression, and feedback** in ~12 phases. Domain changes are scoped and additive; most work lives in `Features/`, `DesignSystem/`, and new specs.

**North star:** A player opens the app, sees a beautiful board with satisfying peg motion, navigates tabs for shop/meta, gets toast/sheet celebrations (not alerts), and has long-term goals beyond prestige.

---

## Locked decisions (v2.0)

| Decision | Value | Rationale |
|----------|-------|-----------|
| Min iOS | 17.0 (unchanged) | `@Observable`, `scrollTargetBehavior`, modern sheets |
| Swift | 5.9+ | Match existing project |
| Navigation | 4-tab `TabView` + root orchestrator | BloomScroll-proven pattern |
| Visual identity | Warm wood + peg orange, dark-mode-aware | Keep peg-game identity; don't clone garden theme |
| Domain rewrite | **No** | `PegGameDomain` stays pure; extend only where UI needs new state |
| Telemetry v2.0 | Still none | Hooks only; Phase 14 deferred |
| Localization v2.0 | Still `en` only | String catalog prep in Phase 11 |
| Board sizes in v2.0 | Classic 15-hole only | Size 6+ deferred to v2.1 unless Phase 9 finishes early |
| Tip jar | Hidden (`AppLinks.tipJar = nil`) | Unchanged |

---

## Non-goals (explicit)

- macOS / widgets / Game Center (layer later)
- iCloud sync (export/import yes; cloud no)
- Multiplayer / social feed
- Replacing peg solitaire with a different core game
- Firebase / analytics in v2.0 ship
- Legal HTML pages (still Phase 15 — link placeholders OK)

---

## Current state vs target state

### Navigation

| Today | Target |
|-------|--------|
| Single `GameView` scroll | `RootView` → TabView (Play · Upgrades · Daily · Awards) |
| Settings sheet only | Settings + Onboarding + WelcomeBack + BoardResult + DailyResult sheets |
| System `alert()` for outcomes | Designed bottom/medium sheets + toast overlay |

### Design system

| Today | Target |
|-------|--------|
| `Theme.swift` — 5 colors, 4 metrics | Full token file + `Card`, `StatTile`, `PrimaryButton`, `PegBackground`, typography scale |
| Stock `.borderedProminent` buttons | Branded button styles with disabled/affordable states |
| No animations | Peg selection, jump arc, board deal, purchase pulse, sheet transitions |
| Haptics/sound toggles unused | Wired to selection, jump, complete, purchase, prestige, achievement |

### Meta progression

| Today | Target |
|-------|--------|
| 3 upgrades, flat list | Level badges, next-effect preview, ×10 / Max buy |
| Prestige as conditional button | Persistent progress meter + confirmation sheet |
| Daily as one row | Dedicated Daily tab: calendar, streak, puzzle entry |
| No achievements | 12–15 milestones with +1% permanent multiplier each |
| No onboarding | 3-page first-run walkthrough |
| No stats/history | Awards tab: achievements + lifetime stats |

---

## Architecture changes

### New folder layout

```
App/
  PegGameIdleApp.swift          # inject RootView instead of GameView
  AppDependencies.swift         # unchanged composition root

Features/
  Shell/
    RootView.swift              # TabView, timer, toasts, sheet routing
    LaunchSplashOverlay.swift   # splash → app crossfade
  Play/
    PlayView.swift              # ex-GameView play column (board + controls)
    BoardView.swift             # enhanced animations
    PlayViewModel.swift         # thin wrapper OR split from GameViewModel
  Upgrades/
    UpgradesView.swift          # full tab (migrate UpgradesSection)
    UpgradeRow.swift
  Daily/
    DailyView.swift             # calendar + streak + start puzzle
    DailyCalendarView.swift
  Awards/
    AwardsView.swift            # achievements list
    StatsSection.swift          # lifetime counters
  Shared/
    CurrencyHeader.swift        # shared stat bar (all tabs)
    ToastView.swift
    BoardResultSheet.swift
    DailyResultSheet.swift
    WelcomeBackSheet.swift
    PrestigeSheet.swift
  Onboarding/
    OnboardingView.swift
  Settings/                     # existing, enhanced

DesignSystem/
  Theme.swift                   # expanded tokens
  Components/
    Card.swift
    StatTile.swift
    BrandedButton.swift
    PegBackground.swift
  Motion/
    PegJumpAnimation.swift
    MotionSafe.swift            # reduce-motion helpers

Support/
  AppLinks.swift
  AccessibilityIdentifiers.swift  # centralized A11y IDs
  DynamicTypeLayout.swift       # ViewThatFits tiers
  Haptics.swift                 # reads SettingsStore
  SoundEffects.swift            # optional, reads SettingsStore

Sources/PegGameDomain/
  Achievement.swift             # NEW — milestone definitions + evaluation
  AchievementEngine.swift       # NEW — pure unlock logic
  StatsSnapshot.swift           # NEW — lifetime counters for UI
  (existing files unchanged unless noted)

Data/
  GameStateRepository.swift     # extend persisted state for achievements, onboarding flag
  SettingsStore.swift           # add particles toggle (optional ambient)

specs/
  system/app-shell.md           # NEW — tabs, sheets, timer, toasts
  system/design-system.md       # NEW — tokens, components, motion
  features/achievements.md      # NEW
  features/onboarding.md        # NEW
  features/stats-history.md     # NEW
  (update existing feature specs where UI surface changes)
```

### Dependency rules (unchanged)

- `PegGameDomain` — no SwiftUI, no UserDefaults
- `Features` → `Domain` + `Data` + `DesignSystem`
- `GameViewModel` may grow or split; if split, `RootView` owns tick timer and coordinates child VMs via `@Observable` environment

### ViewModel strategy

**Option A (recommended for v2.0):** Keep single `GameViewModel` as source of truth; inject via `@Environment(GameViewModel.self)` like ScrollBloom. Tab views are thin presenters.

**Option B (v2.1 refactor):** Split into `PlayViewModel`, `EconomyViewModel`, `DailyViewModel` with a coordinator. Only if `GameViewModel` exceeds ~400 lines after overhaul.

---

## Phase breakdown

Each phase ends with: spec update · feature-inventory row · tests green · manual smoke on simulator.

### Phase 0 — Plan & branch hygiene

**Deliverables**
- [ ] This document reviewed and locked
- [ ] `plan/ui-overhaul` branch pushed
- [ ] `docs/agent-build-checklist.md` — add "v2 UI Overhaul" section referencing phases below
- [ ] `specs/README.md` — link new specs (stubs OK)

**Exit criteria:** Team agrees on locked decisions and phase order.

---

### Phase 1 — Design system foundation

**Goal:** Replace ad-hoc styling with reusable tokens and components before restructuring navigation.

**Spec:** `specs/system/design-system.md`

**Tasks**
1. Expand `Theme.swift`:
   - Semantic colors: `background`, `surface`, `surfaceElevated`, `currency`, `prestige`, `accent`, `success`, `warning`, board/peg tokens (light + dark adaptive)
   - Typography: `currencyLarge`, `statLabel`, `statValue`, `sectionTitle`
   - Spacing scale: 4 / 8 / 12 / 16 / 24 / 32
   - Shadow / stroke tokens for cards
2. Implement components:
   - `Card<Content>` — rounded rect, optional highlight stroke (affordable upgrade)
   - `StatTile` — label + monospaced value (BloomScroll `StatsBar` pattern)
   - `BrandedButton` — primary / secondary / destructive styles
   - `PegBackground` — subtle gradient behind board (optional grain texture asset)
3. Add `MotionSafe.swift` — `Animation?` nil when Reduce Motion
4. Add `DynamicTypeLayout.swift` — `usesLargeTypeLayout`, `usesAccessibleLayout`
5. Migrate inline styles in `GameView`, `UpgradesSection`, `SettingsView` to tokens (no nav change yet)

**Tests:** Snapshot-style unit tests optional; manual Dynamic Type smoke at XX Large.

**Exit criteria:** All existing screens render with new components; no visual regressions on board touch targets.

---

### Phase 2 — App shell & tab navigation

**Goal:** Introduce `RootView` + 4 tabs without losing any v1 behavior.

**Spec:** `specs/system/app-shell.md`

**Tasks**
1. Create `RootView`:
   - `TabView` — Play · Upgrades · Daily · Awards
   - Tab tint = `Theme.Colors.accent`
   - Upgrades tab badge = affordable upgrade count
   - Foreground timer (1s Auto-Jumper) at root — move from `GameView`
2. Extract `PlayView` from current `GameView` (board, status, New Board, currency header)
3. Move `UpgradesSection` → `UpgradesView` tab
4. Stub `DailyView` and `AwardsView` ("Coming soon" → filled in Phases 6–7)
5. Shared `CurrencyHeader` on all tabs (or Play-only + compact bar elsewhere — decide in spec)
6. `PegGameIdleApp` → `RootView(repository:settingsStore:)`
7. Centralize accessibility IDs in `Support/AccessibilityIdentifiers.swift`
8. Update UI smoke test for tab bar + identifiers

**Launch args (add to test-plan):**
- `-ui_test_show_onboarding` (stub until Phase 5)
- `-ui_test_offline_report` — force welcome-back sheet

**Exit criteria:** All v1 flows reachable via tabs; CI smoke passes.

---

### Phase 3 — Feedback layer (toasts, haptics, sound)

**Goal:** Wire settings toggles; replace passive state changes with felt feedback.

**Spec:** Update `specs/system/accessibility.md` (haptics), new section in `app-shell.md` for toasts

**Tasks**
1. `Haptics.swift` — light/medium/heavy wrappers; no-op when disabled
2. `SoundEffects.swift` — jump, complete, purchase, prestige (bundle 3–5 short sounds; respect mute switch via AVAudioSession category)
3. `ToastView` + toast queue on `GameViewModel`:
   - Upgrade purchased
   - Achievement unlocked (Phase 7)
   - Prestige available nudge
   - Offline reserve full warning
4. Root overlay with spring transition + `motionSafe`
5. Wire haptics: peg select, legal jump, illegal tap, board complete, buy upgrade, prestige confirm
6. VoiceOver announcements for currency gains (UIAccessibility.post)

**Exit criteria:** Settings haptics/sound toggles visibly change behavior; toasts dismiss ~2.5s; Reduce Motion disables toast slide.

---

### Phase 4 — Board motion & play polish

**Goal:** Make the peg board the hero — motion design is Peg Game's "pollen flash."

**Spec:** Update `specs/features/peg-board.md` § Motion & feedback

**Tasks**
1. **Selection state** — scale + glow ring on selected peg (keep non-color cue for a11y)
2. **Jump animation** — arc or slide from source → destination (~0.25s, `motionSafe`)
3. **Target hint** — pulse valid target holes when peg selected
4. **Board deal** — staggered peg appearance on new board / auto-deal
5. **Invalid move** — subtle shake on source peg
6. **Board container** — `PegBackground` + depth shadow
7. Drag gesture: haptic on hover valid target (iOS 17+ pointer/drag where applicable)
8. Preserve tap-tap fallback unchanged for a11y

**Tests:** Domain tests unchanged; UI test verifies board still accepts taps after animation.

**Exit criteria:** Manual play feels tactile; Auto-Jumper jumps animate without blocking tick.

---

### Phase 5 — Onboarding

**Goal:** First-run education for peg solitaire + idle loop.

**Spec:** `specs/features/onboarding.md`

**Tasks**
1. Persist `hasSeenOnboarding` in game state (migration default `false` for existing saves with `totalBoardsCompleted == 0` only; else `true`)
2. `OnboardingView` — 3 pages:
   - Page 1: Jump pegs over neighbors into empty holes
   - Page 2: Earn Peg Points; fewer pegs left = bigger bonus
   - Page 3: Upgrades + Auto-Jumper + Daily + Prestige overview
3. Sheet presentation: `.medium, .large` detents; large type → `.large` only
4. Skip button + "Get started" on final page
5. Show automatically when `!hasSeenOnboarding`
6. Re-show entry in Settings → Help → "How to play"

**Exit criteria:** Fresh install shows onboarding; returning players skip; UI test hook works.

---

### Phase 6 — Designed sheets (replace alerts)

**Goal:** Eliminate system alerts for game outcomes.

**Spec:** Update `scoring.md`, `daily-puzzle.md`, `idle-economy.md` § Presentation

**Tasks**
1. **WelcomeBackSheet** — offline earnings breakdown (time away, rate, cap hit indicator)
   - Replace offline `alert` in root
   - `presentationDetents` medium/large
2. **BoardResultSheet** — rank badge (Genius / Purty smart / …), jump points, multiplier, streak, total earned
   - Animated rank reveal (scale spring)
   - Primary: "Play On" (dismiss + auto-deal already happened)
3. **DailyResultSheet** — prestige progress granted, streak day count
4. **PrestigeSheet** — confirmation with before/after multiplier, what resets vs persists
   - Replace `confirmationDialog` on prestige row
5. Bind sheets via `GameViewModel` optional presentation models (not raw booleans scattered in views)

**Exit criteria:** Zero `.alert()` for gameplay outcomes; Settings reset keeps confirmation dialog (destructive OK).

---

### Phase 7 — Achievements & Awards tab

**Goal:** Long-term goals beyond prestige.

**Spec:** `specs/features/achievements.md`

**Domain (new)**
```swift
// Achievement.swift — static catalog
enum AchievementID: String, Codable, CaseIterable { ... }

struct AchievementDefinition {
  let id: AchievementID
  let title: String
  let description: String
  let icon: String  // SF Symbol name for UI mapping in Features layer
}

// AchievementEngine.swift
func newlyUnlocked(state: GameState, event: GameEvent) -> [AchievementID]
```

**Suggested milestones (12–15)**

| ID | Trigger |
|----|---------|
| first_jump | First manual jump |
| first_board | First board completed |
| genius | First 1-peg finish |
| streak_3 | 3-day daily streak |
| streak_7 | 7-day daily streak |
| boards_10 | 10 boards completed |
| boards_100 | 100 boards completed |
| upgrade_max | Any upgrade at max level |
| prestige_1 | First prestige |
| prestige_5 | Fifth prestige |
| peg_points_1k | Lifetime 1K Peg Points earned |
| peg_points_1m | Lifetime 1M |
| daily_perfect_week | 7 consecutive daily solves |
| auto_jumper_hour | Auto-Jumper earned X offline (tune) |

**Reward:** +1% permanent multiplier per achievement (stacking, cap optional at +15% — tune in spec)

**UI**
- `AwardsView` — list with locked (??? ) / unlocked rows, progress hints where applicable
- Toast + haptic on unlock
- Stats section below: total boards, best rank, lifetime points, prestiges, play time estimate

**Persistence:** `GameState.unlockedAchievements: Set<AchievementID>`

**Tests:** `AchievementEngineTests` — one test per achievement trigger

**Exit criteria:** Awards tab fully populated; unlock toast fires once per achievement.

---

### Phase 8 — Upgrade shop polish

**Goal:** Match ScrollBloom shop affordances.

**Spec:** Update `specs/features/idle-economy.md` § Upgrade shop UI

**Tasks**
1. `UpgradeRow`:
   - Icon + name + description
   - Level badge (`Lv 3`)
   - Effect line: `+15 → +22 per jump` (computed from domain)
   - Cost with compact formatting
   - Green `Card` highlight when affordable
   - Buy ×1 / ×10 / Max buttons (domain helpers for bulk cost)
2. Max level state — "MAX" badge, disabled buy
3. Purchase animation — brief scale pulse + toast "Peg Value → Lv 4"
4. Empty state: N/A (always 3 upgrades)

**Domain additions (minimal)**
- `EconomyEngine.bulkUpgradeCost(...)` / `maxAffordableLevels(...)`

**Exit criteria:** Upgrades tab badge matches affordable count; bulk buy works; domain tests for bulk math.

---

### Phase 9 — Daily tab

**Goal:** Give daily puzzle its own home.

**Spec:** Update `specs/features/daily-puzzle.md` § Daily tab UI

**Tasks**
1. `DailyView`:
   - Month calendar grid — solved days checkmarked, today highlighted, streak flame
   - Today's puzzle card — seed preview, "Play Daily" CTA
   - Streak counter + prestige progress hint
2. Playing daily switches `PlayView` into daily mode (existing VM logic)
3. After complete → `DailyResultSheet` (Phase 6)
4. Disabled state when already solved today — show score/rank achieved
5. Offline-safe — no network required

**Optional v2.1:** Larger board daily variant — skip unless ahead of schedule

**Exit criteria:** Daily streak visible at a glance; calendar accurate to local timezone.

---

### Phase 10 — Prestige UX

**Goal:** Prestige feels like a milestone, not a hidden button.

**Spec:** Update `idle-economy.md` § Prestige presentation

**Tasks**
1. Persistent **Prestige progress meter** on Play tab (and/or CurrencyHeader when >50% toward threshold)
2. `PrestigeSheet` with breakdown: current multiplier → next, points banked, what resets
3. Post-prestige celebration — full-screen or sheet confetti substitute (respect Reduce Motion)
4. Toast: "Prestiged! ×1.24 → ×1.26 permanent"
5. Haptic: heavy on confirm

**Exit criteria:** Player always knows how close prestige is; no surprise resets.

---

### Phase 11 — Launch splash & ambient polish

**Goal:** Production first impression.

**Tasks**
1. `LaunchSplashOverlay` — match LaunchScreen asset; crossfade ~0.9s into `RootView`
2. Optional **ambient particles** — subtle dust motes or peg silhouettes drifting (Settings toggle "Ambient motion", default on)
3. App icon polish pass — wood + single peg, matches Theme
4. Settings enhancements:
   - Export save JSON / Import with validation
   - Link to onboarding replay
   - Particles toggle
5. String catalog scaffold (`Localizable.xcstrings`) — extract user-facing strings; still English-only

**Exit criteria:** Cold launch feels intentional; export/import round-trips save.

---

### Phase 12 — Accessibility hardening & responsive layout

**Goal:** Close WCAG gate items open from v1.

**Spec:** Update `specs/system/accessibility.md` with evidence table

**Tasks**
1. `ViewThatFits` on: `CurrencyHeader`, `UpgradeRow`, `DailyView` header, prestige meter
2. Dynamic Type audit — XXX Large on iPhone SE and iPad
3. Contrast evidence for all Theme colors (document hex pairs in spec)
4. VoiceOver rotor actions on board (optional: "Jump to targets" rotor)
5. UI accessibility test target — expand beyond smoke:
   - Tab navigation labels
   - Upgrade row combined labels
   - Sheet dismissal accessibility
6. Reduce Motion — document what disables (particles, peg arc, splash, toast slide)

**Exit criteria:** Accessibility spec checklist ≥90% checked with evidence links.

---

### Phase 13 — CI, tests & release prep

**Tasks**
1. Expand `GameViewModelTests` for achievements, onboarding flag, sheet presentation models
2. UI tests: onboarding skip, tab navigation, buy upgrade, daily entry
3. GitHub Actions — add UI test job if not already (simulator)
4. Update `docs/feature-inventory.md` — full v2 row set
5. Update `docs/agent-build-checklist.md` — v2 phases complete
6. `docs/release/2.0.0-checklist.md` — ship gate (TestFlight, screenshots, App Store copy)
7. README — new screenshots, tab structure

**Exit criteria:** CI green; release checklist drafted.

---

### Phase 14 — Deferred (post-v2.0)

| Item | Notes |
|------|-------|
| Game Center daily leaderboard | Deterministic board ready |
| Board size tiers (6+) | Domain supports; upgrade-gated |
| Telemetry | Firebase gated, copy ScrollBloom bootstrap |
| Legal HTML + GitHub Pages | AppLinks URLs |
| Localization | String catalog already extracted |
| Cosmetics / peg skins | Monetization optional |
| iCloud sync | Export/import sufficient for v2 |
| macOS | Catalyst evaluation |

---

## Domain change summary

Minimal, additive-only changes to `PegGameDomain`:

| Addition | Purpose |
|----------|---------|
| `AchievementID`, `AchievementDefinition`, `AchievementEngine` | Awards tab |
| `StatsSnapshot` or extend `GameState` with lifetime counters | Stats section |
| `hasSeenOnboarding: Bool` on `GameState` | Onboarding |
| `unlockedAchievements: Set<AchievementID>` | Persistence |
| `achievementMultiplier` computed property | +1% per unlock |
| `bulkUpgradeCost`, `maxAffordableLevels` | Shop ×10/Max |
| `GameEvent` enum | Central hook for achievement evaluation |

**No changes** to board rules, scoring math, daily seed algorithm, or prestige formula unless balancing during playtest.

---

## GameViewModel evolution

New presentation state (suggested):

```swift
// Sheet models
var offlineReport: OfflineReport?
var boardResult: BoardResultPresentation?
var dailyResult: DailyResultPresentation?
var prestigePresentation: PrestigePresentation?

// Toast
var toast: ToastItem?

// Tab badge
var affordableUpgradeCount: Int { ... }

// Onboarding
func markOnboardingSeen()
func evaluateAchievements(for event: GameEvent)
```

Keep tick, persistence, and domain calls centralized.

---

## Testing strategy

| Layer | Scope |
|-------|--------|
| Domain unit | Achievements, bulk upgrade math, stats snapshots, onboarding migration |
| App unit | GameViewModel sheet triggers, toast queue, badge count |
| UI smoke | Launch, tabs, settings, play one jump |
| UI a11y | Identifiers contract per `AccessibilityIdentifiers.swift` |
| Manual QA | Dynamic Type, VoiceOver, iPad landscape, offline return, daily midnight rollover |

**Regression rule:** Every phase must keep existing 48+ domain tests green.

---

## Migration & save compatibility

1. Additive `GameState` fields with decode defaults:
   - `hasSeenOnboarding` — `true` if `totalBoardsCompleted > 0` else `false`
   - `unlockedAchievements` — `[]`
   - Lifetime stats — backfill from existing counters where possible
2. Bump `GameState.schemaVersion` if present; migration in repository
3. Export format includes version field for import validation

---

## Branch & PR workflow

```
main
 └── plan/ui-overhaul          ← this plan (docs only PR first)
      └── feature/v2-design-system     (Phase 1)
      └── feature/v2-app-shell         (Phase 2)
      └── feature/v2-feedback          (Phase 3)
      ... (one branch per phase OR batch 1–3, 4–6, 7–9, 10–13)
      └── release/v2.0.0               (integration + QA)
```

**PR rules**
- Each PR updates relevant spec + feature-inventory row
- No phase merges with failing CI
- Prefer vertical slices (e.g. Phase 2 stubs Daily/Awards but ships shell)

**Suggested batching for agent work**

| Batch | Phases | Est. effort |
|-------|--------|-------------|
| A — Foundation | 1, 2, 3 | Medium |
| B — Feel | 4, 5, 6 | Large |
| C — Meta | 7, 8, 9, 10 | Large |
| D — Ship | 11, 12, 13 | Medium |

---

## Success metrics (qualitative)

- [ ] No gameplay outcome uses system `alert()`
- [ ] Settings haptics/sound toggles affect play
- [ ] 4 tabs with shared visual language
- [ ] New player completes onboarding and understands jump + economy
- [ ] Returning player sees welcome-back sheet with earnings breakdown
- [ ] 12+ achievements unlockable with toast feedback
- [ ] Upgrade shop shows level + next effect + bulk buy
- [ ] Daily tab shows calendar + streak
- [ ] WCAG checklist ≥90% with evidence
- [ ] CI: domain + app unit + UI smoke green

---

## Reference files (ScrollBloom)

Copy patterns, not pixels:

| Pattern | ScrollBloom file |
|---------|------------------|
| Tab shell + timer | `ScrollBloom/Views/RootView.swift` |
| Theme + Card + background | `ScrollBloom/Views/Theme.swift` |
| Stats bar | `ScrollBloom/Views/StatsBar.swift` |
| Toasts | `RootView.swift` → `ToastView` |
| Welcome back | `ScrollBloom/Views/WelcomeBackView.swift` |
| Onboarding | `ScrollBloom/Views/OnboardingView.swift` |
| Shop row | `ScrollBloom/Views/PlantsView.swift` → `PlantRow` |
| Dynamic Type | `ScrollBloom/Support/DynamicTypeLayout.swift` |
| Achievements | `ScrollBloom/Views/AchievementsView.swift` |
| App shell spec | `BloomScroll/specs/AppShellSpec.md` |

---

## Open questions (resolve before Phase 2)

1. **CurrencyHeader placement** — all tabs vs Play-only? (Recommend: compact bar on all tabs like ScrollBloom `StatsBar`.)
2. **Achievement multiplier cap** — uncapped +15% or soft cap? (Recommend: cap at +15%, tune in playtest.)
3. **Sound design** — realistic wood clicks vs playful bloops? (Recommend: subtle wood tap + soft chime on rank.)
4. **Daily calendar timezone** — device local vs UTC? (Existing domain uses local; keep.)
5. **GameViewModel split** — defer to v2.1 unless file >400 lines after Phase 10.

---

## Document history

| Date | Author | Change |
|------|--------|--------|
| 2026-06-20 | Agent | Initial draft on `plan/ui-overhaul` |
