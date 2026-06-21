import Foundation
import PegGameDomain

/// Composition root. Constructs and holds the app's shared dependencies so
/// features receive protocols rather than reaching for globals.
@MainActor
public final class AppDependencies {
    public let gameStateRepository: GameStateRepository
    public let settingsStore: SettingsStore
    /// Whether analytics may emit. Off in 1.0 and forced off by `-disable_telemetry`.
    public let telemetryEnabled: Bool

    public init(
        gameStateRepository: GameStateRepository = UserDefaultsGameStateRepository(),
        settingsStore: SettingsStore = UserDefaultsSettingsStore(),
        telemetryEnabled: Bool = false
    ) {
        self.gameStateRepository = gameStateRepository
        self.settingsStore = settingsStore
        self.telemetryEnabled = telemetryEnabled
    }

    /// Builds dependencies for the running app, honoring test/dogfood launch
    /// arguments (see `specs/system/test-plan.md`).
    public static func live(arguments: [String] = ProcessInfo.processInfo.arguments) -> AppDependencies {
        let repository = UserDefaultsGameStateRepository()
        if arguments.contains("-reset_state") {
            repository.reset()
        }
        // Telemetry is not implemented in 1.0, so it ships off; `-disable_telemetry`
        // keeps it off for test/dogfood builds once it exists.
        let telemetry = false && !arguments.contains("-disable_telemetry")
        return AppDependencies(
            gameStateRepository: repository,
            settingsStore: UserDefaultsSettingsStore(),
            telemetryEnabled: telemetry
        )
    }
}
