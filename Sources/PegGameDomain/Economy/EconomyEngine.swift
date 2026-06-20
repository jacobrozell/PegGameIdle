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

    // MARK: Prestige

    /// Lifetime jumps required to bank one prestige point (the resource that
    /// permanently raises the global multiplier).
    public static let jumpsPerPrestigePoint: Double = 500

    /// Each banked prestige point adds this much to the global multiplier.
    public static let prestigeMultiplierPerPoint: Double = 0.1

    /// Prestige points currently available to claim (beyond those already banked).
    public static func pendingPrestige(in state: GameState) -> Double {
        let earnable = (Double(state.totalPegsJumped) / jumpsPerPrestigePoint).squareRoot().rounded(.down)
        return max(0, earnable - state.prestigePointsClaimed)
    }

    public static func canPrestige(_ state: GameState) -> Bool {
        pendingPrestige(in: state) >= 1
    }

    /// The multiplier the player would have after prestiging right now.
    public static func projectedMultiplier(after state: GameState) -> Double {
        let total = state.prestigePointsClaimed + pendingPrestige(in: state)
        return 1 + total * prestigeMultiplierPerPoint
    }

    /// Banks pending prestige points: raises the permanent multiplier and resets
    /// spendable progress (Peg Points + upgrade levels). Lifetime jumps are kept
    /// so prestige value is monotonic. Returns the original state unchanged if
    /// nothing is claimable.
    public static func prestige(_ state: GameState) -> GameState {
        let pending = pendingPrestige(in: state)
        guard pending >= 1 else { return state }
        var next = state
        next.prestigePointsClaimed += pending
        next.prestigeMultiplier = 1 + next.prestigePointsClaimed * prestigeMultiplierPerPoint
        next.pegPoints = 0
        next.upgradeLevels = [:]
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
