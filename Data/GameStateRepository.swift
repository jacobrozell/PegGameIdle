import Foundation
import PegGameDomain

/// Persistence boundary for idle progress. Features depend on this protocol,
/// never on a concrete store, so tests can substitute an in-memory fake.
public protocol GameStateRepository {
    func load() -> GameState
    func save(_ state: GameState)
}

/// Simple `UserDefaults`-backed store. The state is small (a few numbers and
/// upgrade levels), so JSON in user defaults is sufficient for v1; migration to
/// SwiftData is a Phase-4 follow-up if the schema grows.
public final class UserDefaultsGameStateRepository: GameStateRepository {
    private let defaults: UserDefaults
    private let key = "peggameidle.state.v1"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func load() -> GameState {
        guard
            let data = defaults.data(forKey: key),
            let state = try? JSONDecoder().decode(GameState.self, from: data)
        else {
            return GameState()
        }
        return state
    }

    public func save(_ state: GameState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        defaults.set(data, forKey: key)
    }
}

/// In-memory repository for previews and tests.
public final class InMemoryGameStateRepository: GameStateRepository {
    private var state: GameState
    public init(state: GameState = GameState()) { self.state = state }
    public func load() -> GameState { state }
    public func save(_ state: GameState) { self.state = state }
}
