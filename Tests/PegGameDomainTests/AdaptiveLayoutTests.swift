import XCTest
@testable import PegGameDomain

final class AdaptiveLayoutTests: XCTestCase {

    func testIpadLandscapeUsesTwoColumns() {
        XCTAssertTrue(AdaptiveLayout.usesSideBySide(idiom: .pad, isLandscape: true))
    }

    func testIpadPortraitStacks() {
        XCTAssertFalse(AdaptiveLayout.usesSideBySide(idiom: .pad, isLandscape: false))
    }

    func testPhoneAlwaysStacksEvenInLandscape() {
        // Guards the Pro-Max-landscape (regular width) trap: still a phone.
        XCTAssertFalse(AdaptiveLayout.usesSideBySide(idiom: .phone, isLandscape: true))
        XCTAssertFalse(AdaptiveLayout.usesSideBySide(idiom: .phone, isLandscape: false))
    }
}
