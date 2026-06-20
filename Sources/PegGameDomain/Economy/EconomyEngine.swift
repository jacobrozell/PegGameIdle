import Foundation

/// Pure functions that advance the idle economy. The engine never mutates in
/// place from the outside — callers pass state in and get new state out, which
/// keeps it trivially testable and free of hidden time dependencies.
public enum EconomyEngine {

    public enum PurchaseError: Error, Equatable {
        case insufficientFunds(needed: Double, have: Double)
    }

    /// Awards Peg Points for a batch of pegs jumped (manual play).
    public static func awardJumps(_ count: Int, to state: GameState) -> GameState {
        guard count > 0 else { return state }
        var next = state
        next.pegPoints += state.reward(forJumping: count)
        next.totalPegsJumped += count
        return next
    }

    /// Cost to raise `kind` by one level from the current state.
    public static func cost(of kind: UpgradeKind, in state: GameState) -> Double {
        kind.cost(atLevel: state.level(of: kind))
    }

    /// Buys one level of `kind`. Throws if funds are insufficient.
    public static func purchase(_ kind: UpgradeKind, in state: GameState) throws -> GameState {
        let price = cost(of: kind, in: state)
        guard state.pegPoints >= price else {
            throw PurchaseError.insufficientFunds(needed: price, have: state.pegPoints)
        }
        var next = state
        next.pegPoints -= price
        next.upgradeLevels[kind, default: 0] += 1
        return next
    }

    /// The result of reconciling time the player spent away.
    public struct OfflineReport: Equatable {
        public let jumps: Int
        public let pegPointsEarned: Double
        public let effectiveSeconds: Double
        public let wasCapped: Bool
    }

    /// Reconciles idle Auto-Jumper earnings for the elapsed time and returns the
    /// updated state plus a report for the "welcome back" UI.
    ///
    /// - Parameters:
    ///   - now: current time (injected for determinism).
    ///   - state: last persisted state, including `lastSeen`.
    public static func reconcileOffline(now: Date, state: GameState) -> (state: GameState, report: OfflineReport) {
        let rate = state.autoJumpsPerSecond
        let elapsed = max(0, now.timeIntervalSince(state.lastSeen))
        let cap = state.offlineCapHours * 3600
        let effective = min(elapsed, cap)

        var next = state
        next.lastSeen = now

        guard rate > 0, effective > 0 else {
            return (next, OfflineReport(jumps: 0, pegPointsEarned: 0, effectiveSeconds: effective, wasCapped: elapsed > cap))
        }

        let jumps = Int((rate * effective).rounded(.down))
        let earned = state.reward(forJumping: jumps)
        next.pegPoints += earned
        next.totalPegsJumped += jumps

        return (
            next,
            OfflineReport(
                jumps: jumps,
                pegPointsEarned: earned,
                effectiveSeconds: effective,
                wasCapped: elapsed > cap
            )
        )
    }
}
