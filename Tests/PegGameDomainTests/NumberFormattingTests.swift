import XCTest
@testable import PegGameDomain

final class NumberFormattingTests: XCTestCase {

    func testSmallValuesAreWholeNumbers() {
        XCTAssertEqual(NumberFormatting.compact(0), "0")
        XCTAssertEqual(NumberFormatting.compact(7), "7")
        XCTAssertEqual(NumberFormatting.compact(999), "999")
        XCTAssertEqual(NumberFormatting.compact(42.9), "42")
    }

    func testThousands() {
        XCTAssertEqual(NumberFormatting.compact(1000), "1K")
        XCTAssertEqual(NumberFormatting.compact(1200), "1.2K")
        XCTAssertEqual(NumberFormatting.compact(1234), "1.23K")
        XCTAssertEqual(NumberFormatting.compact(999_999), "999.99K")
    }

    func testMillionsAndBillions() {
        XCTAssertEqual(NumberFormatting.compact(1_000_000), "1M")
        XCTAssertEqual(NumberFormatting.compact(2_500_000), "2.5M")
        XCTAssertEqual(NumberFormatting.compact(1_000_000_000), "1B")
    }

    func testNegativeAndNonFinite() {
        XCTAssertEqual(NumberFormatting.compact(-1500), "-1.5K")
        XCTAssertEqual(NumberFormatting.compact(.infinity), "∞")
    }
}
