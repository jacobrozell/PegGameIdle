import XCTest

/// Phase 6 / Phase 12 UI smoke: launch, tab bar, and core play controls.
final class GameUISmokeTests: XCTestCase {

    func testCoreScreenLaunchesWithKeyControls() {
        let app = XCUIApplication()
        app.launchArguments += ["-reset_state", "-disable_telemetry"]
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Play"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.tabBars.buttons["Upgrades"].exists)
        XCTAssertTrue(app.tabBars.buttons["Daily"].exists)
        XCTAssertTrue(app.tabBars.buttons["Awards"].exists)

        XCTAssertTrue(app.descendants(matching: .any)["peg-points-value"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["status-line"].firstMatch.exists)
        XCTAssertTrue(app.buttons["new-board-button"].exists)
        XCTAssertTrue(app.buttons["undo-button"].exists)
        XCTAssertTrue(app.buttons["hint-button"].exists)
        XCTAssertTrue(app.buttons["hole-0-0"].exists)

        app.tabBars.buttons["Upgrades"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["upgrade-pegValue"].firstMatch.waitForExistence(timeout: 5))

        app.tabBars.buttons["Daily"].tap()
        XCTAssertTrue(app.buttons["daily-play-button"].waitForExistence(timeout: 5))

        app.tabBars.buttons["Awards"].tap()
        XCTAssertTrue(app.navigationBars["Awards"].waitForExistence(timeout: 5))
    }

    func testSettingsOpensFromPlayTab() {
        let app = XCUIApplication()
        app.launchArguments += ["-reset_state", "-disable_telemetry"]
        app.launch()

        XCTAssertTrue(app.buttons["settings-button"].waitForExistence(timeout: 8))
        app.buttons["settings-button"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.switches["settings-haptics-toggle"].exists)
        XCTAssertTrue(app.switches["settings-particles-toggle"].exists)
    }

    func testOnboardingSkipReachesPlayTab() {
        let app = XCUIApplication()
        app.launchArguments += ["-reset_state", "-ui_test_show_onboarding"]
        app.launch()

        XCTAssertTrue(app.buttons["onboarding-skip"].waitForExistence(timeout: 8))
        app.buttons["onboarding-skip"].tap()
        XCTAssertTrue(app.buttons["new-board-button"].waitForExistence(timeout: 5))
    }

    func testBuyUpgradeWhenRichState() {
        let app = XCUIApplication()
        app.launchArguments += ["-reset_state", "-ui_test_rich_state"]
        app.launch()

        app.tabBars.buttons["Upgrades"].tap()
        let buy = app.buttons["upgrade-buy-pegValue-1"]
        XCTAssertTrue(buy.waitForExistence(timeout: 8))
        buy.tap()
        XCTAssertTrue(app.descendants(matching: .any)["peg-points-value"].firstMatch.waitForExistence(timeout: 5))
    }
}
