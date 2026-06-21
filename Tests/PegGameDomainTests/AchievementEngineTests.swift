import XCTest
@testable import PegGameDomain

final class AchievementEngineTests: XCTestCase {

    func testFirstJumpUnlocks() {
        let state = GameState(manualJumps: 1)
        let ids = AchievementEngine.newlyUnlocked(state: state, event: .manualJump)
        XCTAssertTrue(ids.contains(.firstJump))
    }

    func testFirstBoardUnlocks() {
        let state = GameState(totalBoardsCompleted: 1)
        let ids = AchievementEngine.newlyUnlocked(state: state, event: .boardCompleted(pegsLeft: 5))
        XCTAssertTrue(ids.contains(.firstBoard))
    }

    func testGeniusUnlocksOnOnePegLeft() {
        let state = GameState(totalBoardsCompleted: 1)
        let ids = AchievementEngine.newlyUnlocked(state: state, event: .boardCompleted(pegsLeft: 1))
        XCTAssertTrue(ids.contains(.genius))
    }

    func testPrestigeUnlocks() {
        let state = GameState(totalPrestiges: 1)
        let ids = AchievementEngine.newlyUnlocked(state: state, event: .prestigePerformed(totalPrestiges: 1))
        XCTAssertTrue(ids.contains(.prestige1))
    }

    func testAlreadyUnlockedNotReturned() {
        var state = GameState(unlockedAchievements: [.firstJump])
        state.manualJumps = 5
        let ids = AchievementEngine.newlyUnlocked(state: state, event: .manualJump)
        XCTAssertFalse(ids.contains(.firstJump))
    }

    func testAchievementMultiplierScalesAndCaps() {
        let mult12 = AchievementEngine.achievementMultiplier(unlocked: Set(AchievementID.allCases))
        XCTAssertEqual(mult12, 1.12, accuracy: 0.001)
        XCTAssertEqual(AchievementEngine.maxBonus, 0.15)
    }
}
