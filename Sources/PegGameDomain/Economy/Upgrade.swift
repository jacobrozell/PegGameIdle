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
    /// Unlocks larger boards with more pegs per run.
    case boardSize

    /// Default repeatable cap for most upgrades.
    public static let maxLevel = 25

    /// Per-upgrade level cap (board size tops out at 8-hole rows).
    public var levelCap: Int {
        switch self {
        case .boardSize: return 3
        default: return Self.maxLevel
        }
    }

    public var displayName: String {
        switch self {
        case .pegValue: return "Peg Value"
        case .autoJumperSpeed: return "Auto-Jumper Speed"
        case .offlineReserve: return "Offline Reserve"
        case .boardSize: return "Board Size"
        }
    }

    public var detail: String {
        switch self {
        case .pegValue: return "More Peg Points for every peg you jump."
        case .autoJumperSpeed: return "The Auto-Jumper clears pegs faster."
        case .offlineReserve: return "Bank more idle earnings while you're away."
        case .boardSize: return "Play on bigger boards with more jumps per run."
        }
    }

    public var icon: String {
        switch self {
        case .pegValue: return "dollarsign.circle.fill"
        case .autoJumperSpeed: return "bolt.fill"
        case .offlineReserve: return "moon.zzz.fill"
        case .boardSize: return "square.grid.3x3.fill"
        }
    }

    /// Human-readable effect at `level` for shop UI.
    public func effectDescription(at level: Int) -> String {
        switch self {
        case .pegValue:
            return "+\(NumberFormatting.compact(UpgradeEffect.pegValue(level: level))) per jump"
        case .autoJumperSpeed:
            let rate = UpgradeEffect.autoJumpsPerSecond(level: level)
            return rate > 0 ? String(format: "%.1f jumps/s", rate) : "Idle auto-play"
        case .offlineReserve:
            return "\(Int(UpgradeEffect.offlineCapHours(level: level)))h offline cap"
        case .boardSize:
            return UpgradeEffect.boardLayout(level: level).displayName
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
        case .boardSize:       base = 500; growth = 1.55
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

    /// Board geometry at `boardSize` level: classic (5) through 8 rows.
    public static func boardLayout(level: Int) -> BoardLayout {
        BoardLayout(size: min(5 + max(0, level), 8))
    }
}
