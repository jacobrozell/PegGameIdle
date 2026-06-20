import XCTest
@testable import PegGameDomain

/// Deterministic RNG so auto-play behavior is reproducible in tests.
private struct SeededRNG: RandomNumberGenerator {
    var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 0x9E3779B97F4A7C15 : seed }
    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}

final class AutoPlayerTests: XCTestCase {

    func testAutoPlayerOnlyProducesLegalMoves() {
        let player = AutoPlayer(strategy: .greedy)
        var rng = SeededRNG(seed: 42)
        var board = Board(layout: .classic, empty: Position(row: 0, col: 0))

        while let move = player.nextMove(on: board, using: &rng) {
            XCTAssertTrue(board.isLegal(move), "Auto-player produced an illegal move: \(move)")
            board.apply(move)
        }
        XCTAssertTrue(board.isGameOver)
    }

    func testPlayOutReducesBoardToGameOver() {
        let player = AutoPlayer(strategy: .greedy)
        var rng = SeededRNG(seed: 7)
        let board = Board(layout: .classic, empty: Position(row: 0, col: 0))
        let moves = player.playOut(board, using: &rng)

        // Each jump removes exactly one peg; 14 pegs can yield at most 13 jumps.
        XCTAssertGreaterThan(moves.count, 0)
        XCTAssertLessThanOrEqual(moves.count, 13)

        var replay = board
        for move in moves { XCTAssertTrue(replay.apply(move)) }
        XCTAssertTrue(replay.isGameOver)
        XCTAssertEqual(replay.pegCount, board.pegCount - moves.count)
    }

    func testDeterministicWithSameSeed() {
        let player = AutoPlayer(strategy: .random)
        let board = Board(layout: .classic, empty: Position(row: 0, col: 0))

        var rngA = SeededRNG(seed: 99)
        var rngB = SeededRNG(seed: 99)
        XCTAssertEqual(player.playOut(board, using: &rngA), player.playOut(board, using: &rngB))
    }

    func testReturnsNilOnFinishedBoard() {
        let player = AutoPlayer(strategy: .greedy)
        var rng = SeededRNG(seed: 1)
        let solved = Board(layout: .classic, pegs: [Position(row: 0, col: 0)])
        XCTAssertNil(player.nextMove(on: solved, using: &rng))
    }
}
