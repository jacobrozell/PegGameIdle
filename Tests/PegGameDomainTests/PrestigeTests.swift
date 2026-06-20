import XCTest
@testable import PegGameDomain

final class PrestigeTests: XCTestCase {

    func testNoPendingPrestigeEarly() {
        let state = GameState(totalPegsJumped: 100)
        XCTAssertEqual(EconomyEngine.pendingPrestige(in: state), 0)
        XCTAssertFalse(EconomyEngine.canPrestige(state))
    }

    func testPendingPrestigeGrowsWithSqrtOfLifetimeJumps() {
        // sqrt(500/500) = 1 ; sqrt(2000/500) = 2 ; sqrt(4500/500) = 3
        XCTAssertEqual(EconomyEngine.pendingPrestige(in: GameState(totalPegsJumped: 500)), 1)
        XCTAssertEqual(EconomyEngine.pendingPrestige(in: GameState(totalPegsJumped: 2000)), 2)
        XCTAssertEqual(EconomyEngine.pendingPrestige(in: GameState(totalPegsJumped: 4500)), 3)
    }

    func testPrestigeBanksPointsRaisesMultiplierAndResetsProgress() {
        var state = GameState(pegPoints: 9999, totalPegsJumped: 2000)
        state.upgradeLevels[.pegValue] = 5
        XCTAssertTrue(EconomyEngine.canPrestige(state))

        let after = EconomyEngine.prestige(state)
        XCTAssertEqual(after.prestigePointsClaimed, 2)
        XCTAssertEqual(after.prestigeMultiplier, 1.2, accuracy: 0.0001) // 1 + 2*0.1
        XCTAssertEqual(after.pegPoints, 0)
        XCTAssertEqual(after.level(of: .pegValue), 0)
        XCTAssertEqual(after.totalPegsJumped, 2000, "lifetime jumps persist across prestige")
    }

    func testPrestigeIsNoOpWhenNothingPending() {
        let state = GameState(pegPoints: 50, totalPegsJumped: 100)
        XCTAssertEqual(EconomyEngine.prestige(state), state)
    }

    func testPrestigeRewardScalesAfterBanking() {
        let state = GameState(totalPegsJumped: 2000)
        let after = EconomyEngine.prestige(state)
        // Base pegValue 1 * 1.2 multiplier.
        XCTAssertEqual(after.reward(forJumping: 10), 12, accuracy: 0.0001)
    }

    func testPendingDropsAfterClaimingUntilMoreJumpsAccrue() {
        let state = GameState(totalPegsJumped: 2000)
        let after = EconomyEngine.prestige(state) // claims 2
        XCTAssertEqual(EconomyEngine.pendingPrestige(in: after), 0)
        XCTAssertFalse(EconomyEngine.canPrestige(after))
    }
}
