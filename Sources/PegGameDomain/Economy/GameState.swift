import Foundation

/// The persisted idle-game progress: currency, upgrade levels, and totals.
///
/// This is a pure value type so it can be serialized by the persistence layer
/// and reasoned about in tests without a database.
public struct GameState: Equatable, Sendable, Codable {
    /// Spendable currency.
    public var pegPoints: Double
    /// Permanent prestige multiplier applied to all Peg Point gains.
    public var prestigeMultiplier: Double
    /// Lifetime count of pegs jumped (manual + auto).
    public var totalPegsJumped: Int
    /// Current level of each upgrade.
    public var upgradeLevels: [UpgradeKind: Int]
    /// Lifetime prestige points already claimed. Drives `prestigeMultiplier`.
    public var prestigePointsClaimed: Double
    /// Current run of streak-worthy board finishes. Resets on a weak finish.
    public var streakCount: Int
    /// Bonus prestige progress earned from Daily Puzzles (jump-equivalent).
    public var dailyPrestigeJumps: Double
    /// Consecutive days the Daily Puzzle was completed.
    public var dailyStreak: Int
    /// UTC day number of the last Daily Puzzle claim, if any.
    public var lastDailyDay: Int?
    /// When earnings were last reconciled. Drives offline accrual.
    public var lastSeen: Date

    public init(
        pegPoints: Double = 0,
        prestigeMultiplier: Double = 1,
        totalPegsJumped: Int = 0,
        upgradeLevels: [UpgradeKind: Int] = [:],
        prestigePointsClaimed: Double = 0,
        streakCount: Int = 0,
        dailyPrestigeJumps: Double = 0,
        dailyStreak: Int = 0,
        lastDailyDay: Int? = nil,
        lastSeen: Date = .init()
    ) {
        self.pegPoints = pegPoints
        self.prestigeMultiplier = prestigeMultiplier
        self.totalPegsJumped = totalPegsJumped
        self.upgradeLevels = upgradeLevels
        self.prestigePointsClaimed = prestigePointsClaimed
        self.streakCount = streakCount
        self.dailyPrestigeJumps = dailyPrestigeJumps
        self.dailyStreak = dailyStreak
        self.lastDailyDay = lastDailyDay
        self.lastSeen = lastSeen
    }

    // Tolerant decoding: a save written before a field existed still loads.
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        pegPoints = try c.decodeIfPresent(Double.self, forKey: .pegPoints) ?? 0
        prestigeMultiplier = try c.decodeIfPresent(Double.self, forKey: .prestigeMultiplier) ?? 1
        totalPegsJumped = try c.decodeIfPresent(Int.self, forKey: .totalPegsJumped) ?? 0
        upgradeLevels = try c.decodeIfPresent([UpgradeKind: Int].self, forKey: .upgradeLevels) ?? [:]
        prestigePointsClaimed = try c.decodeIfPresent(Double.self, forKey: .prestigePointsClaimed) ?? 0
        streakCount = try c.decodeIfPresent(Int.self, forKey: .streakCount) ?? 0
        dailyPrestigeJumps = try c.decodeIfPresent(Double.self, forKey: .dailyPrestigeJumps) ?? 0
        dailyStreak = try c.decodeIfPresent(Int.self, forKey: .dailyStreak) ?? 0
        lastDailyDay = try c.decodeIfPresent(Int.self, forKey: .lastDailyDay)
        lastSeen = try c.decodeIfPresent(Date.self, forKey: .lastSeen) ?? Date()
    }

    public func level(of kind: UpgradeKind) -> Int { upgradeLevels[kind] ?? 0 }

    // MARK: Derived effects

    public var pegValue: Double { UpgradeEffect.pegValue(level: level(of: .pegValue)) }
    public var autoJumpsPerSecond: Double { UpgradeEffect.autoJumpsPerSecond(level: level(of: .autoJumperSpeed)) }
    public var offlineCapHours: Double { UpgradeEffect.offlineCapHours(level: level(of: .offlineReserve)) }

    /// Peg Points awarded for jumping `count` pegs right now.
    public func reward(forJumping count: Int) -> Double {
        Double(count) * pegValue * prestigeMultiplier
    }
}
