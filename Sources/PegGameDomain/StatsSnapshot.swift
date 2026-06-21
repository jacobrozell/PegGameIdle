import Foundation

/// Lifetime counters for the Awards tab stats section.
public struct StatsSnapshot: Equatable, Sendable {
    public let totalBoardsCompleted: Int
    public let bestRank: BoardRank?
    public let lifetimePegPointsEarned: Double
    public let totalPrestiges: Int
    public let totalPegsJumped: Int
    public let unlockedAchievementCount: Int
    public let achievementMultiplier: Double

    public init(state: GameState) {
        totalBoardsCompleted = state.totalBoardsCompleted
        bestRank = state.bestRank
        lifetimePegPointsEarned = state.lifetimePegPointsEarned
        totalPrestiges = state.totalPrestiges
        totalPegsJumped = state.totalPegsJumped
        unlockedAchievementCount = state.unlockedAchievements.count
        achievementMultiplier = state.achievementMultiplier
    }
}
