import XCTest
@testable import PegGameIdle

final class SettingsStoreTests: XCTestCase {

    func testInvalidThemeFallsBackToSlate() {
        let defaults = UserDefaults(suiteName: "SettingsStoreTests.invalidTheme")!
        defaults.removePersistentDomain(forName: "SettingsStoreTests.invalidTheme")
        defaults.set("not-a-real-theme", forKey: "peggameidle.settings.colorTheme")

        let store = UserDefaultsSettingsStore(defaults: defaults)
        XCTAssertEqual(store.colorTheme, .slate)
        XCTAssertEqual(defaults.string(forKey: "peggameidle.settings.colorTheme"), AppColorTheme.slate.rawValue)
    }

    func testThemeRoundTrips() {
        let defaults = UserDefaults(suiteName: "SettingsStoreTests.roundTrip")!
        defaults.removePersistentDomain(forName: "SettingsStoreTests.roundTrip")

        let store = UserDefaultsSettingsStore(defaults: defaults)
        store.colorTheme = .ocean
        XCTAssertEqual(store.colorTheme, .ocean)
    }
}
