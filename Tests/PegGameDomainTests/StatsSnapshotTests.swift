import XCTest
@testable import PegGameDomain

final class StatsSnapshotTests: XCTestCase {
    func testIncludesDailyStreak() {
        let state = GameState(dailyStreak: 7, totalBoardsCompleted: 3)
        let snap = StatsSnapshot(state: state)
        XCTAssertEqual(snap.dailyStreak, 7)
        XCTAssertEqual(snap.totalBoardsCompleted, 3)
    }
}
