import Foundation

/// Hooks for achievement evaluation after meaningful game actions.
public enum GameEvent: Equatable, Sendable {
    case manualJump
    case boardCompleted(pegsLeft: Int)
    case upgradePurchased(kind: UpgradeKind, newLevel: Int)
    case prestigePerformed(totalPrestiges: Int)
    case dailyCompleted(streak: Int)
    case offlineReconciled(jumps: Int, pegPoints: Double)
}
