import XCTest

/// Phase 6 / Phase 12 UI smoke: launch, tab bar, and core play controls.
final class GameUISmokeTests: XCTestCase {

    func testCoreScreenLaunchesWithKeyControls() {
        let app = XCUIApplication()
        app.launchArguments += ["-reset_state", "-disable_telemetry"]
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["tab-play"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.tabBars.buttons["tab-upgrades"].exists)
        XCTAssertTrue(app.tabBars.buttons["tab-daily"].exists)
        XCTAssertTrue(app.tabBars.buttons["tab-awards"].exists)

        XCTAssertTrue(app.staticTexts["peg-points-value"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.otherElements["status-line"].exists || app.staticTexts["status-line"].exists)
        XCTAssertTrue(app.buttons["new-board-button"].exists)
        XCTAssertTrue(app.buttons["hole-0-0"].exists)

        app.tabBars.buttons["tab-upgrades"].tap()
        XCTAssertTrue(app.buttons["upgrade-pegValue"].waitForExistence(timeout: 3))

        app.tabBars.buttons["tab-daily"].tap()
        XCTAssertTrue(app.buttons["daily-play-button"].waitForExistence(timeout: 3))

        app.tabBars.buttons["tab-awards"].tap()
        XCTAssertTrue(app.staticTexts["Awards"].waitForExistence(timeout: 3))
    }

    func testOnboardingSkipReachesPlayTab() {
        let app = XCUIApplication()
        app.launchArguments += ["-reset_state", "-ui_test_show_onboarding"]
        app.launch()

        XCTAssertTrue(app.buttons["Skip"].waitForExistence(timeout: 5))
        app.buttons["Skip"].tap()
        XCTAssertTrue(app.buttons["new-board-button"].waitForExistence(timeout: 5))
    }
}
