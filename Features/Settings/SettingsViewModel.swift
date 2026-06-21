import Foundation
import Observation

/// Backs the Settings screen: exposes preferences and persists each change.
@MainActor
@Observable
public final class SettingsViewModel {
    private let store: SettingsStore

    public init(store: SettingsStore) {
        self.store = store
        self.hapticsEnabled = store.hapticsEnabled
        self.soundEnabled = store.soundEnabled
        self.ambientParticlesEnabled = store.ambientParticlesEnabled
    }

    public var hapticsEnabled: Bool {
        didSet { store.hapticsEnabled = hapticsEnabled }
    }

    public var soundEnabled: Bool {
        didSet { store.soundEnabled = soundEnabled }
    }

    public var ambientParticlesEnabled: Bool {
        didSet { store.ambientParticlesEnabled = ambientParticlesEnabled }
    }
}
