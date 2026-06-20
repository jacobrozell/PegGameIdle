import Foundation
import PegGameDomain

/// Composition root. Constructs and holds the app's shared dependencies so
/// features receive protocols rather than reaching for globals.
@MainActor
public final class AppDependencies {
    public let gameStateRepository: GameStateRepository

    public init(gameStateRepository: GameStateRepository = UserDefaultsGameStateRepository()) {
        self.gameStateRepository = gameStateRepository
    }
}
