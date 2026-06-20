import XCTest
@testable import PegGameDomain

final class EconomyTests: XCTestCase {

    func testBasePegValueAndReward() {
        let state = GameState()
        XCTAssertEqual(state.pegValue, 1.0)
        XCTAssertEqual(state.reward(forJumping: 5), 5.0)
    }

    func testAwardJumpsAddsPointsAndTotals() {
        var state = GameState()
        state = EconomyEngine.awardJumps(3, to: state)
        XCTAssertEqual(state.pegPoints, 3)
        XCTAssertEqual(state.totalPegsJumped, 3)
    }

    func testPrestigeMultiplierScalesReward() {
        var state = GameState(prestigeMultiplier: 2.5)
        state = EconomyEngine.awardJumps(4, to: state)
        XCTAssertEqual(state.pegPoints, 10)
    }

    func testPurchaseDeductsCostAndRaisesLevel() throws {
        var state = GameState(pegPoints: 1000)
        let price = EconomyEngine.cost(of: .pegValue, in: state)
        state = try EconomyEngine.purchase(.pegValue, in: state)
        XCTAssertEqual(state.level(of: .pegValue), 1)
        XCTAssertEqual(state.pegPoints, 1000 - price)
        XCTAssertEqual(state.pegValue, 2.0) // base 1 + level 1
    }

    func testPurchaseThrowsWhenBroke() {
        let state = GameState(pegPoints: 0)
        XCTAssertThrowsError(try EconomyEngine.purchase(.pegValue, in: state)) { error in
            guard case EconomyEngine.PurchaseError.insufficientFunds = error else {
                return XCTFail("Expected insufficientFunds, got \(error)")
            }
        }
    }

    func testUpgradeCostGrowsWithLevel() {
        XCTAssertLessThan(UpgradeKind.pegValue.cost(atLevel: 0), UpgradeKind.pegValue.cost(atLevel: 5))
    }

    func testOfflineWithoutAutoJumperEarnsNothing() {
        let start = Date(timeIntervalSince1970: 1_000_000)
        let state = GameState(lastSeen: start)
        let later = start.addingTimeInterval(3600)
        let result = EconomyEngine.reconcileOffline(now: later, state: state)
        XCTAssertEqual(result.report.jumps, 0)
        XCTAssertEqual(result.report.pegPointsEarned, 0)
        XCTAssertEqual(result.state.lastSeen, later)
    }

    func testOfflineEarningsAccrueAtAutoJumperRate() {
        let start = Date(timeIntervalSince1970: 1_000_000)
        var state = GameState(lastSeen: start)
        state.upgradeLevels[.autoJumperSpeed] = 2 // 1.0 jumps/sec
        let later = start.addingTimeInterval(100) // 100 seconds

        let result = EconomyEngine.reconcileOffline(now: later, state: state)
        XCTAssertEqual(result.report.jumps, 100)
        XCTAssertEqual(result.report.pegPointsEarned, 100) // pegValue 1 * 100
        XCTAssertFalse(result.report.wasCapped)
        XCTAssertEqual(result.state.pegPoints, 100)
    }

    func testOfflineEarningsAreCapped() {
        let start = Date(timeIntervalSince1970: 1_000_000)
        var state = GameState(lastSeen: start)
        state.upgradeLevels[.autoJumperSpeed] = 2 // 1.0 jumps/sec
        // Level 0 offline reserve = 2 hours cap.
        let twoDaysLater = start.addingTimeInterval(48 * 3600)

        let result = EconomyEngine.reconcileOffline(now: twoDaysLater, state: state)
        XCTAssertTrue(result.report.wasCapped)
        XCTAssertEqual(result.report.effectiveSeconds, 2 * 3600)
        XCTAssertEqual(result.report.jumps, 2 * 3600) // 1 jump/sec for 2h
    }

    func testCodableRoundTripState() throws {
        var state = GameState(pegPoints: 123.5, prestigeMultiplier: 3, totalPegsJumped: 42)
        state.upgradeLevels[.pegValue] = 4
        let data = try JSONEncoder().encode(state)
        let decoded = try JSONDecoder().decode(GameState.self, from: data)
        XCTAssertEqual(state, decoded)
    }
}
