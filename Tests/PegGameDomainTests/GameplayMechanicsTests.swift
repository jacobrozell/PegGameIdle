import XCTest
@testable import PegGameDomain

final class GameplayMechanicsTests: XCTestCase {

    func testReverseInvalidStateReturnsFalse() {
        var board = Board(layout: .classic, empty: Position(row: 0, col: 0))
        let move = board.legalMoves().first!
        XCTAssertTrue(board.apply(move))
        let bogus = Move(from: move.to, over: move.from, to: move.over)
        XCTAssertFalse(board.reverse(bogus))
    }

    func testReverseMoveRestoresBoard() {
        var board = Board(layout: .classic, empty: Position(row: 0, col: 0))
        let move = board.legalMoves().first!
        let before = board.pegs
        XCTAssertTrue(board.apply(move))
        XCTAssertTrue(board.reverse(move))
        XCTAssertEqual(board.pegs, before)
    }

    func testHintReturnsLegalMove() {
        let board = Board(layout: .classic, empty: Position(row: 0, col: 0))
        let hint = BoardHint.suggestedMove(on: board)
        XCTAssertNotNil(hint)
        XCTAssertTrue(board.isLegal(hint!))
    }

    func testFollowingHintsFromClassicStartReachesOnePeg() {
        var board = Board(layout: .classic, empty: Position(row: 0, col: 0))
        var step = 0
        while let hint = BoardHint.suggestedMove(on: board) {
            XCTAssertTrue(board.isLegal(hint), "Illegal hint at step \(step): \(hint)")
            board.apply(hint)
            step += 1
            XCTAssertLessThanOrEqual(step, 13)
        }
        XCTAssertTrue(board.isGameOver)
        XCTAssertEqual(board.pegCount, 1, "Hints should lead to a perfect solve, not \(board.pegCount) pegs")
    }

    func testRevertManualJumpUndoesEconomy() {
        var state = GameState(pegPoints: 10, totalPegsJumped: 5, manualJumps: 3, lifetimePegPointsEarned: 10)
        let reward = state.reward(forJumping: 1)
        state = EconomyEngine.awardJumps(1, to: state, manual: true)
        state = EconomyEngine.revertManualJump(reward: reward, in: state)
        XCTAssertEqual(state.pegPoints, 10, accuracy: 0.0001)
        XCTAssertEqual(state.totalPegsJumped, 5)
        XCTAssertEqual(state.manualJumps, 3)
    }

    func testRankDisplayNamesAreNeutral() {
        XCTAssertEqual(BoardRank(pegsLeft: 1).displayName, "Expert")
        XCTAssertEqual(BoardRank(pegsLeft: 2).displayName, "Sharp")
        XCTAssertEqual(BoardRank(pegsLeft: 3).displayName, "Fair")
        XCTAssertEqual(BoardRank(pegsLeft: 5).displayName, "Rough")
    }

    func testCenterPegBonusRequiresExactlyOnePeg() {
        let layout = BoardLayout.classic
        let center = layout.centerPosition
        let state = GameState()
        let (_, result) = EconomyEngine.completeBoard(
            pegsLeft: 1,
            finalPeg: center,
            boardLayout: layout,
            boardEarnings: 100,
            state: state
        )
        XCTAssertTrue(result.landedCenterPeg)
        XCTAssertEqual(result.centerPegBonusMultiplier, 1.5, accuracy: 0.0001)
        // genius bonus 100 * 4 * 1.1 streak * 1.5 center = 660
        XCTAssertEqual(result.bonusAwarded, 660, accuracy: 0.0001)
    }

    func testCenterPegBonusNotAppliedWithMultiplePegs() {
        let layout = BoardLayout.classic
        let (_, result) = EconomyEngine.completeBoard(
            pegsLeft: 2,
            finalPeg: layout.centerPosition,
            boardLayout: layout,
            boardEarnings: 100,
            state: GameState()
        )
        XCTAssertFalse(result.landedCenterPeg)
    }

    func testBoardSizeUpgradeUnlocksLargerLayout() {
        XCTAssertEqual(UpgradeEffect.boardLayout(level: 0).size, 5)
        XCTAssertEqual(UpgradeEffect.boardLayout(level: 1).size, 6)
        XCTAssertEqual(UpgradeEffect.boardLayout(level: 3).size, 8)
        XCTAssertEqual(UpgradeEffect.boardLayout(level: 10).size, 8)
    }

    func testLargerBoardHasMoreStartingPegs() {
        let board = Board(layout: BoardLayout(size: 6), empty: Position(row: 0, col: 0))
        XCTAssertEqual(board.pegCount, 20)
    }
}
