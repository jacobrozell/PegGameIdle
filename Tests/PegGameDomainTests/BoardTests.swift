import XCTest
@testable import PegGameDomain

final class BoardTests: XCTestCase {

    func testClassicBoardHasFifteenHolesAndFourteenPegs() {
        let board = Board(layout: .classic, empty: Position(row: 0, col: 0))
        XCTAssertEqual(board.layout.holeCount, 15)
        XCTAssertEqual(board.pegCount, 14)
        XCTAssertFalse(board.hasPeg(at: Position(row: 0, col: 0)))
    }

    func testOpeningMovesFromTopEmpty() {
        // With only the apex empty, the two pegs two rows below can jump up.
        let board = Board(layout: .classic, empty: Position(row: 0, col: 0))
        let moves = board.legalMoves()
        XCTAssertEqual(moves.count, 2)
        let landingHoles = Set(moves.map(\.to))
        XCTAssertEqual(landingHoles, [Position(row: 0, col: 0)])
    }

    func testApplyingLegalMoveRemovesJumpedPeg() {
        var board = Board(layout: .classic, empty: Position(row: 0, col: 0))
        let move = board.legalMoves().first!
        let before = board.pegCount
        XCTAssertTrue(board.apply(move))
        XCTAssertEqual(board.pegCount, before - 1)
        XCTAssertTrue(board.hasPeg(at: move.to))
        XCTAssertFalse(board.hasPeg(at: move.from))
        XCTAssertFalse(board.hasPeg(at: move.over))
    }

    func testIllegalMoveIsRejected() {
        var board = Board(layout: .classic, empty: Position(row: 0, col: 0))
        let bogus = Move(
            from: Position(row: 4, col: 0),
            over: Position(row: 4, col: 1),
            to: Position(row: 4, col: 2)
        )
        // (4,2) is occupied, so this jump has no empty landing hole.
        XCTAssertFalse(board.isLegal(bogus))
        XCTAssertFalse(board.apply(bogus))
        XCTAssertEqual(board.pegCount, 14)
    }

    func testNonAdjacentJumpIsRejected() {
        var board = Board(layout: .classic, empty: Position(row: 0, col: 0))
        let tooFar = Move(
            from: Position(row: 3, col: 0),
            over: Position(row: 2, col: 0),
            to: Position(row: 0, col: 0)
        )
        XCTAssertFalse(board.isLegal(tooFar))
        XCTAssertFalse(board.apply(tooFar))
    }

    func testSolvedBoardIsRecognized() {
        let solved = Board(layout: .classic, pegs: [Position(row: 0, col: 0)])
        XCTAssertTrue(solved.isSolved)
        XCTAssertTrue(solved.isGameOver)
    }

    func testGameOverWhenNoMovesRemain() {
        // Two pegs far apart, no legal jump between them.
        let stuck = Board(layout: .classic, pegs: [
            Position(row: 0, col: 0),
            Position(row: 4, col: 4),
        ])
        XCTAssertTrue(stuck.isGameOver)
        XCTAssertFalse(stuck.isSolved)
    }

    func testCodableRoundTrip() throws {
        let board = Board(layout: .classic, empty: Position(row: 2, col: 1))
        let data = try JSONEncoder().encode(board)
        let decoded = try JSONDecoder().decode(Board.self, from: data)
        XCTAssertEqual(board, decoded)
    }
}
