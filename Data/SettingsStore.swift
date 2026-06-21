import Foundation

/// User preferences that outlive a session. Behind a protocol so features
/// depend on the abstraction and tests can use an in-memory double.
public protocol SettingsStore: AnyObject {
    var hapticsEnabled: Bool { get set }
    var soundEnabled: Bool { get set }
    var ambientParticlesEnabled: Bool { get set }
}

public final class UserDefaultsSettingsStore: SettingsStore {
    private enum Key {
        static let haptics = "peggameidle.settings.haptics"
        static let sound = "peggameidle.settings.sound"
        static let particles = "peggameidle.settings.particles"
    }

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if defaults.object(forKey: Key.haptics) == nil { defaults.set(true, forKey: Key.haptics) }
        if defaults.object(forKey: Key.sound) == nil { defaults.set(true, forKey: Key.sound) }
        if defaults.object(forKey: Key.particles) == nil { defaults.set(true, forKey: Key.particles) }
    }

    public var hapticsEnabled: Bool {
        get { defaults.bool(forKey: Key.haptics) }
        set { defaults.set(newValue, forKey: Key.haptics) }
    }

    public var soundEnabled: Bool {
        get { defaults.bool(forKey: Key.sound) }
        set { defaults.set(newValue, forKey: Key.sound) }
    }

    public var ambientParticlesEnabled: Bool {
        get { defaults.bool(forKey: Key.particles) }
        set { defaults.set(newValue, forKey: Key.particles) }
    }
}

public final class InMemorySettingsStore: SettingsStore {
    public var hapticsEnabled: Bool
    public var soundEnabled: Bool
    public var ambientParticlesEnabled: Bool

    public init(hapticsEnabled: Bool = true, soundEnabled: Bool = true, ambientParticlesEnabled: Bool = true) {
        self.hapticsEnabled = hapticsEnabled
        self.soundEnabled = soundEnabled
        self.ambientParticlesEnabled = ambientParticlesEnabled
    }
}
