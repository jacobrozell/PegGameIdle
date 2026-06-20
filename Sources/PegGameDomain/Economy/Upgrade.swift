import Foundation

/// A purchasable, repeatable upgrade in the idle economy.
///
/// Each upgrade has a level. Buying raises the level and increases its effect;
/// cost grows geometrically with level so progression stays exponential, the
/// hallmark of the idle genre.
public enum UpgradeKind: String, CaseIterable, Sendable, Codable {
    /// Increases Peg Points earned per peg jumped.
    case pegValue
    /// Increases how fast the Auto-Jumper plays (jumps per second).
    case autoJumperSpeed
    /// Increases the offline-earnings cap (hours of accrual collected on return).
    case offlineReserve

    public var displayName: String {
        switch self {
        case .pegValue: return "Peg Value"
        case .autoJumperSpeed: return "Auto-Jumper Speed"
        case .offlineReserve: return "Offline Reserve"
        }
    }

    public var detail: String {
        switch self {
        case .pegValue: return "More Peg Points for every peg you jump."
        case .autoJumperSpeed: return "The Auto-Jumper clears pegs faster."
        case .offlineReserve: return "Bank more idle earnings while you're away."
        }
    }

    /// Cost of the *next* level given the current level, in Peg Points.
    public func cost(atLevel level: Int) -> Double {
        let base: Double
        let growth: Double
        switch self {
        case .pegValue:        base = 25;  growth = 1.18
        case .autoJumperSpeed: base = 100; growth = 1.30
        case .offlineReserve:  base = 250; growth = 1.45
        }
        return (base * pow(growth, Double(level))).rounded()
    }
}

/// The numeric effect of an upgrade at a given level.
public enum UpgradeEffect {
    /// Peg Points earned per peg jumped at `pegValue` level.
    public static func pegValue(level: Int) -> Double {
        1.0 + Double(level)
    }

    /// Auto-Jumper jumps per second at `autoJumperSpeed` level.
    public static func autoJumpsPerSecond(level: Int) -> Double {
        guard level > 0 else { return 0 }
        return 0.5 * Double(level)
    }

    /// Maximum hours of offline earnings banked at `offlineReserve` level.
    public static func offlineCapHours(level: Int) -> Double {
        2.0 + 2.0 * Double(level)
    }
}
