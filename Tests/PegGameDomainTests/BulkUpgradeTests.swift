import XCTest
@testable import PegGameDomain

final class BulkUpgradeTests: XCTestCase {

    func testBulkCostSumsLevels() {
        let state = GameState(pegPoints: 10_000)
        let single = EconomyEngine.cost(of: .pegValue, in: state)
        let bulk = EconomyEngine.bulkUpgradeCost(.pegValue, levels: 3, in: state)
        var expected = 0.0
        for i in 0..<3 {
            expected += UpgradeKind.pegValue.cost(atLevel: i)
        }
        XCTAssertEqual(bulk, expected)
        XCTAssertGreaterThan(bulk, single)
    }

    func testMaxAffordableRespectsFunds() {
        let state = GameState(pegPoints: 50)
        let count = EconomyEngine.maxAffordableLevels(.pegValue, in: state)
        XCTAssertGreaterThan(count, 0)
        let cost = EconomyEngine.bulkUpgradeCost(.pegValue, levels: count, in: state)
        XCTAssertLessThanOrEqual(cost, state.pegPoints)
        let oneMore = EconomyEngine.bulkUpgradeCost(.pegValue, levels: count + 1, in: state)
        XCTAssertGreaterThan(oneMore, state.pegPoints)
    }

    func testPurchaseBulkAppliesLevels() {
        let state = GameState(pegPoints: 10_000)
        let next = EconomyEngine.purchaseBulk(.pegValue, levels: 5, in: state)
        XCTAssertEqual(next.level(of: .pegValue), 5)
        XCTAssertLessThan(next.pegPoints, state.pegPoints)
    }

    func testPurchaseAtMaxLevelThrows() {
        let state = GameState(upgradeLevels: [.pegValue: UpgradeKind.maxLevel])
        XCTAssertThrowsError(try EconomyEngine.purchase(.pegValue, in: state)) { error in
            XCTAssertEqual(error as? EconomyEngine.PurchaseError, .maxLevelReached)
        }
    }
}
