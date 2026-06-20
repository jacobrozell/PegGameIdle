import Foundation

/// User preferences that outlive a session. Behind a protocol so features
/// depend on the abstraction and tests can use an in-memory double.
public protocol SettingsStore: AnyObject {
    var hapticsEnabled: Bool { get set }
    var soundEnabled: Bool { get set }
}

public final class UserDefaultsSettingsStore: SettingsStore {
    private enum Key {
        static let haptics = "peggameidle.settings.haptics"
        static let sound = "peggameidle.settings.sound"
    }

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        // Default both on for a new install.
        if defaults.object(forKey: Key.haptics) == nil { defaults.set(true, forKey: Key.haptics) }
        if defaults.object(forKey: Key.sound) == nil { defaults.set(true, forKey: Key.sound) }
    }

    public var hapticsEnabled: Bool {
        get { defaults.bool(forKey: Key.haptics) }
        set { defaults.set(newValue, forKey: Key.haptics) }
    }

    public var soundEnabled: Bool {
        get { defaults.bool(forKey: Key.sound) }
        set { defaults.set(newValue, forKey: Key.sound) }
    }
}

public final class InMemorySettingsStore: SettingsStore {
    public var hapticsEnabled: Bool
    public var soundEnabled: Bool
    public init(hapticsEnabled: Bool = true, soundEnabled: Bool = true) {
        self.hapticsEnabled = hapticsEnabled
        self.soundEnabled = soundEnabled
    }
}
