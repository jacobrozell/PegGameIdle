import XCTest
@testable import PegGameDomain

final class DailyPuzzleTests: XCTestCase {

    private func date(day: Int) -> Date {
        Date(timeIntervalSince1970: Double(day) * 86_400 + 100)
    }

    func testSameDayProducesSameBoard() {
        let a1 = DailyPuzzle.board(for: date(day: 20_000))
        let a2 = DailyPuzzle.board(for: date(day: 20_000).addingTimeInterval(3600))
        XCTAssertEqual(a1, a2, "same UTC day -> identical board")
    }

    func testBoardsVaryAcrossDays() {
        // Any single adjacent pair could collide (~1/15); across many days the
        // generator must produce more than one distinct board.
        let boards = (20_000..<20_020).map { DailyPuzzle.board(for: date(day: $0)) }
        XCTAssertGreaterThan(Set(boards.map(\.pegs)).count, 1)
    }

    func testDailyBoardIsValidClassicWithOneEmptyHole() {
        let board = DailyPuzzle.board(for: date(day: 19_999))
        XCTAssertEqual(board.layout, .classic)
        XCTAssertEqual(board.pegCount, 14)
    }

    func testDayNumberIncrementsEachDay() {
        XCTAssertEqual(DailyPuzzle.dayNumber(for: date(day: 100)), 100)
        XCTAssertEqual(DailyPuzzle.dayNumber(for: date(day: 101)), 101)
    }

    func testFirstClaimAwardsPrestigeJumps() {
        let state = GameState()
        let (next, result) = EconomyEngine.completeDaily(pegsLeft: 1, on: date(day: 500), state: state)
        XCTAssertFalse(result.alreadyClaimed)
        XCTAssertEqual(result.dailyStreak, 1)
        // genius mult 5 * base 100 * streak(1.0)
        XCTAssertEqual(result.prestigeJumpsAwarded, 500, accuracy: 0.0001)
        XCTAssertEqual(next.dailyPrestigeJumps, 500, accuracy: 0.0001)
        XCTAssertEqual(next.lastDailyDay, 500)
        XCTAssertEqual(next.lastDailyRank, .genius)
        XCTAssertEqual(next.lastDailyPegsLeft, 1)
    }

    func testSecondClaimSameDayIsNoOp() {
        let state = GameState()
        let first = EconomyEngine.completeDaily(pegsLeft: 1, on: date(day: 500), state: state)
        let second = EconomyEngine.completeDaily(pegsLeft: 1, on: date(day: 500), state: first.state)
        XCTAssertTrue(second.result.alreadyClaimed)
        XCTAssertEqual(second.result.prestigeJumpsAwarded, 0)
        XCTAssertEqual(second.state.dailyPrestigeJumps, first.state.dailyPrestigeJumps)
    }

    func testConsecutiveDaysExtendStreakGapResets() {
        let state = GameState()
        let d1 = EconomyEngine.completeDaily(pegsLeft: 2, on: date(day: 500), state: state)
        let d2 = EconomyEngine.completeDaily(pegsLeft: 2, on: date(day: 501), state: d1.state)
        XCTAssertEqual(d2.result.dailyStreak, 2)

        // Skip a day -> streak resets to 1.
        let d4 = EconomyEngine.completeDaily(pegsLeft: 2, on: date(day: 503), state: d2.state)
        XCTAssertEqual(d4.result.dailyStreak, 1)
    }

    func testDailyJumpsFeedPrestigeProgress() {
        var state = GameState()
        // No real jumps, but a strong daily haul should approach a prestige point.
        for day in 600..<610 {
            state = EconomyEngine.completeDaily(pegsLeft: 1, on: date(day: day), state: state).state
        }
        XCTAssertGreaterThan(EconomyEngine.pendingPrestige(in: state), 0)
    }
}
