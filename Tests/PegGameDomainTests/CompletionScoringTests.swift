import XCTest
@testable import PegGameDomain

final class CompletionScoringTests: XCTestCase {

    func testRankFromPegsLeft() {
        XCTAssertEqual(BoardRank(pegsLeft: 1), .genius)
        XCTAssertEqual(BoardRank(pegsLeft: 2), .purtySmart)
        XCTAssertEqual(BoardRank(pegsLeft: 3), .justPlainDumb)
        XCTAssertEqual(BoardRank(pegsLeft: 4), .egNoRaMoose)
        XCTAssertEqual(BoardRank(pegsLeft: 7), .egNoRaMoose)
    }

    func testCompletionMultipliers() {
        XCTAssertEqual(BoardRank(pegsLeft: 1).completionMultiplier(pegsLeft: 1), 5.0)
        XCTAssertEqual(BoardRank(pegsLeft: 2).completionMultiplier(pegsLeft: 2), 3.0)
        XCTAssertEqual(BoardRank(pegsLeft: 3).completionMultiplier(pegsLeft: 3), 2.0)
        XCTAssertEqual(BoardRank(pegsLeft: 4).completionMultiplier(pegsLeft: 4), 1.25)
        XCTAssertEqual(BoardRank(pegsLeft: 8).completionMultiplier(pegsLeft: 8), 1.0)
    }

    func testGeniusBoardPaysFullCompletionBonus() {
        let state = GameState()
        let (next, result) = EconomyEngine.completeBoard(pegsLeft: 1, boardEarnings: 100, state: state)
        // streak 1 -> streakMult 1.1 ; bonus = 100 * (5-1) * 1.1
        XCTAssertEqual(result.rank, .genius)
        XCTAssertEqual(result.streakCount, 1)
        XCTAssertEqual(result.bonusAwarded, 440, accuracy: 0.0001)
        XCTAssertEqual(next.pegPoints, 440, accuracy: 0.0001)
    }

    func testSloppyBoardForgoesBonusAndResetsStreak() {
        var state = GameState()
        state.streakCount = 3
        let (next, result) = EconomyEngine.completeBoard(pegsLeft: 6, boardEarnings: 100, state: state)
        XCTAssertEqual(result.rank, .egNoRaMoose)
        XCTAssertEqual(result.bonusAwarded, 0)
        XCTAssertEqual(result.streakCount, 0, "a weak finish resets the streak")
        XCTAssertEqual(next.pegPoints, 0, "no currency is ever subtracted")
    }

    func testStreakGrowsBonusAcrossGoodBoards() {
        var state = GameState()
        let first = EconomyEngine.completeBoard(pegsLeft: 2, boardEarnings: 100, state: state)
        state = first.state
        let second = EconomyEngine.completeBoard(pegsLeft: 1, boardEarnings: 100, state: state)
        XCTAssertEqual(first.result.streakCount, 1)
        XCTAssertEqual(second.result.streakCount, 2)
        // second: streakMult 1.2, genius -> 100 * 4 * 1.2
        XCTAssertEqual(second.result.bonusAwarded, 480, accuracy: 0.0001)
    }
}
