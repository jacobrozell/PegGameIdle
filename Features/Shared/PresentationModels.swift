import Foundation
import PegGameDomain

/// Toast overlay item shown at the root.
public struct ToastItem: Equatable, Identifiable {
    public let id = UUID()
    public let message: String
    public var isAchievement: Bool = false

    public init(message: String, isAchievement: Bool = false) {
        self.message = message
        self.isAchievement = isAchievement
    }
}

extension EconomyEngine.OfflineReport: @retroactive Identifiable {
    public var id: String { "\(jumps)-\(pegPointsEarned)-\(effectiveSeconds)" }
}

extension EconomyEngine.BoardResult: @retroactive Identifiable {
    public var id: String { "\(pegsLeft)-\(rank.rawValue)-\(bonusAwarded)" }
}

extension EconomyEngine.DailyResult: @retroactive Identifiable {
    public var id: String { "\(dayNumber)-\(rank.rawValue)" }
}

public struct PrestigePresentation: Equatable, Identifiable {
    public let id = UUID()
    public let pendingPoints: Int
    public let currentMultiplier: Double
    public let projectedMultiplier: Double

    public init(pendingPoints: Int, currentMultiplier: Double, projectedMultiplier: Double) {
        self.pendingPoints = pendingPoints
        self.currentMultiplier = currentMultiplier
        self.projectedMultiplier = projectedMultiplier
    }
}
