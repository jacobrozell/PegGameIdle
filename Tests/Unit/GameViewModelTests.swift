import XCTest
import CoreGraphics
import PegGameDomain
@testable import PegGameIdle

/// Player-interaction and drag tests for the core game view model. These run
/// against an in-memory repository (no simulator, no UI), so they're fast and
/// deterministic while still exercising the real domain wiring.
@MainActor
final class GameViewModelTests: XCTestCase {

    private func makeViewModel(state: GameState = GameState()) -> GameViewModel {
        GameViewModel(repository: InMemoryGameStateRepository(state: state), now: Date())
    }

    // Apex empty: the peg at (2,0) has exactly one legal jump, up-right to (0,0).
    private let jumper = Position(row: 2, col: 0)
    private let apex = Position(row: 0, col: 0)

    // MARK: Initial state

    func testInitialState() {
        let vm = makeViewModel()
        XCTAssertEqual(vm.pegsRemaining, 14)
        XCTAssertEqual(vm.pegPoints, 0)
        XCTAssertEqual(vm.autoJumpsPerSecond, 0)
        XCTAssertFalse(vm.isDailyMode)
        XCTAssertFalse(vm.isSelected(jumper))
    }

    // MARK: Tap interaction

    func testTapSelectsPegAndHighlightsLegalTargets() {
        let vm = makeViewModel()
        vm.tap(jumper)
        XCTAssertTrue(vm.isSelected(jumper))
        XCTAssertTrue(vm.isTarget(apex))
    }

    func testTapTargetPerformsJumpAndAwardsPoint() {
        let vm = makeViewModel()
        vm.tap(jumper)   // select
        vm.tap(apex)     // jump into the empty apex
        XCTAssertEqual(vm.pegsRemaining, 13)
        XCTAssertEqual(vm.pegPoints, 1) // base pegValue 1
        XCTAssertTrue(vm.board.hasPeg(at: apex))
        XCTAssertFalse(vm.board.hasPeg(at: jumper))
        XCTAssertFalse(vm.isSelected(jumper), "selection clears after a jump")
    }

    func testTappingSamePegDeselects() {
        let vm = makeViewModel()
        vm.tap(jumper)
        vm.tap(jumper)
        XCTAssertFalse(vm.isSelected(jumper))
    }

    func testTappingEmptyHoleClearsSelection() {
        let vm = makeViewModel()
        vm.tap(apex) // apex is empty -> no selection
        XCTAssertFalse(vm.isSelected(apex))
    }

    // MARK: Drag interaction

    func testDragInLegalDirectionPerformsJump() {
        let vm = makeViewModel()
        vm.beginDrag(from: jumper)
        // (2,0) -> (0,0) is up and slightly right: translation up (-y), right (+x).
        vm.endDrag(from: jumper, translation: CGSize(width: 20, height: -60))
        XCTAssertEqual(vm.pegsRemaining, 13)
        XCTAssertTrue(vm.board.hasPeg(at: apex))
        XCTAssertFalse(vm.board.hasPeg(at: jumper))
    }

    func testDragInIllegalDirectionDoesNothing() {
        let vm = makeViewModel()
        vm.beginDrag(from: jumper)
        // Straight down: no legal jump exists that way from (2,0).
        vm.endDrag(from: jumper, translation: CGSize(width: 0, height: 60))
        XCTAssertEqual(vm.pegsRemaining, 14)
        XCTAssertTrue(vm.board.hasPeg(at: jumper))
    }

    func testTinyDragKeepsSelectionWithoutJumping() {
        let vm = makeViewModel()
        vm.beginDrag(from: jumper)
        vm.endDrag(from: jumper, translation: CGSize(width: 0.4, height: 0.4))
        XCTAssertEqual(vm.pegsRemaining, 14, "a tap-sized drag must not jump")
        XCTAssertTrue(vm.isSelected(jumper), "it stays selected so a tap can follow")
    }

    func testDragFromEmptyHoleIsHarmless() {
        let vm = makeViewModel()
        vm.endDrag(from: apex, translation: CGSize(width: 20, height: -60))
        XCTAssertEqual(vm.pegsRemaining, 14)
    }

    // MARK: Auto-Jumper (idle)

    func testAutoJumperEarnsOnOwnBoardWithoutTouchingHumanBoard() {
        // autoJumperSpeed level 20 -> 10 jumps/sec.
        let vm = makeViewModel(state: GameState(upgradeLevels: [.autoJumperSpeed: 20]))
        let humanPegsBefore = vm.pegsRemaining
        vm.tickAutoJumper(seconds: 100) // ~1000 attempted jumps across auto boards
        XCTAssertGreaterThan(vm.pegPoints, 0, "idle play earns Peg Points")
        XCTAssertEqual(vm.pegsRemaining, humanPegsBefore, "auto-jumper must not disturb the human board")
    }

    func testAutoJumperIdleWhenSpeedIsZero() {
        let vm = makeViewModel()
        vm.tickAutoJumper(seconds: 10)
        XCTAssertEqual(vm.pegPoints, 0)
    }

    // MARK: Upgrades

    func testPurchaseUpgradeWhenAffordable() {
        let vm = makeViewModel(state: GameState(pegPoints: 1000))
        vm.purchase(.autoJumperSpeed)
        XCTAssertGreaterThan(vm.autoJumpsPerSecond, 0)
        XCTAssertLessThan(vm.pegPoints, 1000)
    }

    func testPurchaseIgnoredWhenBroke() {
        let vm = makeViewModel()
        vm.purchase(.pegValue)
        XCTAssertEqual(vm.pegPoints, 0)
        XCTAssertFalse(vm.canAfford(.autoJumperSpeed))
    }

    // MARK: Daily puzzle & reset

    func testStartDailyPuzzleEntersDailyMode() {
        let vm = makeViewModel()
        vm.startDailyPuzzle(now: Date(timeIntervalSince1970: 1_000_000))
        XCTAssertTrue(vm.isDailyMode)
        XCTAssertEqual(vm.pegsRemaining, 14)
    }

    func testResetAllProgressWipesState() {
        let vm = makeViewModel(state: GameState(pegPoints: 500, totalPegsJumped: 999))
        vm.resetAllProgress()
        XCTAssertEqual(vm.pegPoints, 0)
        XCTAssertEqual(vm.pegsRemaining, 14)
        XCTAssertFalse(vm.isDailyMode)
    }
}
