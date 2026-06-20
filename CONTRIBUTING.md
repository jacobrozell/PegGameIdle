# Contributing

Read this before changing code. Agents: this is your style + process contract.

## Architecture rules (non-negotiable)
1. **Spec-first.** No user-visible behavior without an authoritative spec in
   `specs/`. One source of truth per concern. Update the spec's Verification
   block when behavior changes.
2. **Domain is pure.** `Sources/PegGameDomain` imports no SwiftUI and no
   persistence framework. If logic is hard to unit-test, it's in the wrong layer.
3. **Test-first for domain.** Pure logic and view models get unit tests before
   UI polish. Run `swift test`.
4. **Features depend on protocols** (`any GameStateRepository`), never concrete
   stores. Wire dependencies in `App/AppDependencies.swift`.
5. **No business rules in `View.body`.** Views call view models; view models call
   the domain.
6. **XcodeGen is the source of truth** for the project. Edit `project.yml`;
   never commit the generated `.xcodeproj`.

## Accessibility is a release gate (WCAG 2.1 AA)
Every interactive control ships `accessibilityLabel`, `accessibilityHint`, and
`accessibilityIdentifier`. Targets ≥ 44pt. Never encode meaning in color alone.
See `specs/system/accessibility.md` for the identifier contract.

## Tests
- Domain: `swift test` (fast, CI/Linux-safe).
- UI: XCUITest in `Tests/UI`, addressed by accessibility identifier.
- Add a regression test named for any bug you fix.

## Commits
Small, focused, descriptive. Reference the spec/feature you touched. Update
`docs/feature-inventory.md` when a feature's shipped status changes and
`docs/agent-build-checklist.md`'s progress log when a phase advances.

## Secrets
Never commit signing assets, service plists, or API keys (see `.gitignore`).
