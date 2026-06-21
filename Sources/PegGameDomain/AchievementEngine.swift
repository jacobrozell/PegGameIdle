import Foundation

public enum AchievementEngine {
    /// +1% per unlock, capped at +15%.
    public static let bonusPerAchievement = 0.01
    public static let maxBonus = 0.15

    public static func achievementMultiplier(unlocked: Set<AchievementID>) -> Double {
        min(Double(unlocked.count) * bonusPerAchievement, maxBonus) + 1
    }

    /// Returns achievement IDs newly satisfied by `state` after `event`, excluding already unlocked.
    public static func newlyUnlocked(state: GameState, event: GameEvent) -> [AchievementID] {
        let candidates = AchievementID.allCases.filter { !state.unlockedAchievements.contains($0) }
        return candidates.filter { isSatisfied($0, state: state, event: event) }
    }

    private static func isSatisfied(_ id: AchievementID, state: GameState, event: GameEvent) -> Bool {
        switch id {
        case .firstJump:
            return state.manualJumps >= 1
        case .firstBoard:
            return state.totalBoardsCompleted >= 1
        case .genius:
            if case .boardCompleted(let pegs, _) = event { return pegs <= 1 }
            return state.bestRank == .genius
        case .streak3:
            return state.dailyStreak >= 3
        case .streak7:
            return state.dailyStreak >= 7
        case .boards10:
            return state.totalBoardsCompleted >= 10
        case .boards100:
            return state.totalBoardsCompleted >= 100
        case .upgradeMax:
            return UpgradeKind.allCases.contains { state.level(of: $0) >= $0.levelCap }
        case .prestige1:
            return state.totalPrestiges >= 1
        case .prestige5:
            return state.totalPrestiges >= 5
        case .pegPoints1k:
            return state.lifetimePegPointsEarned >= 1_000
        case .pegPoints1m:
            return state.lifetimePegPointsEarned >= 1_000_000
        case .centerPeg:
            if case .boardCompleted(_, let center) = event { return center }
            return false
        }
    }
}
