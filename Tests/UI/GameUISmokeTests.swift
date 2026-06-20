import XCTest

/// Phase 6 / Phase 12 `*UISmoke`: proves the core screen launches and its key
/// controls are reachable. Detailed gameplay logic is covered by domain unit
/// tests (`swift test`); this only proves the wiring.
final class GameUISmokeTests: XCTestCase {

    func testCoreScreenLaunchesWithKeyControls() {
        let app = XCUIApplication()
        // Reset state so the run is deterministic (see Phase 12.4).
        app.launchArguments += ["-reset_state", "-disable_telemetry"]
        app.launch()

        XCTAssertTrue(app.staticTexts["peg-points-value"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.otherElements["status-line"].exists || app.staticTexts["status-line"].exists)
        XCTAssertTrue(app.buttons["new-board-button"].exists)
        XCTAssertTrue(app.buttons["hole-0-0"].exists)
        XCTAssertTrue(app.buttons["upgrade-pegValue"].exists)
    }
}
