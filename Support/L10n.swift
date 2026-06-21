import Foundation

/// Localized copy — English-only for 1.0; keys live in `Resources/Localizable.xcstrings`.
enum L10n {
    static let tabPlay = String(localized: "tab.play", defaultValue: "Play")
    static let tabUpgrades = String(localized: "tab.upgrades", defaultValue: "Upgrades")
    static let tabDaily = String(localized: "tab.daily", defaultValue: "Daily")
    static let tabAwards = String(localized: "tab.awards", defaultValue: "Awards")

    static let settingsTitle = String(localized: "settings.title", defaultValue: "Settings")
    static let done = String(localized: "common.done", defaultValue: "Done")
    static let skip = String(localized: "common.skip", defaultValue: "Skip")
    static let getStarted = String(localized: "onboarding.getStarted", defaultValue: "Get started")
    static let next = String(localized: "common.next", defaultValue: "Next")
}
