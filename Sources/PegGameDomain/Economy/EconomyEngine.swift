import Foundation

/// Pure functions that advance the idle economy. The engine never mutates in
/// place from the outside — callers pass state in and get new state out, which
/// keeps it trivially testable and free of hidden time dependencies.
public enum EconomyEngine {

    public enum PurchaseError: Error, Equatable {
        case insufficientFunds(needed: Double, have: Double)
        case maxLevelReached
    }

    private static func recordEarnings(_ amount: Double, in state: inout GameState) {
        guard amount > 0 else { return }
        state.lifetimePegPointsEarned += amount
    }

    /// Awards Peg Points for a batch of pegs jumped (manual play).
    public static func awardJumps(_ count: Int, to state: GameState, manual: Bool = false) -> GameState {
        guard count > 0 else { return state }
        var next = state
        let earned = state.reward(forJumping: count)
        next.pegPoints += earned
        recordEarnings(earned, in: &next)
        next.totalPegsJumped += count
        if manual { next.manualJumps += count }
        return next
    }

    /// Reverses one manual jump's economy effects (used by Undo).
    public static func revertManualJump(reward: Double, in state: GameState) -> GameState {
        var next = state
        next.pegPoints = max(0, next.pegPoints - reward)
        next.lifetimePegPointsEarned = max(0, next.lifetimePegPointsEarned - reward)
        next.totalPegsJumped = max(0, next.totalPegsJumped - 1)
        next.manualJumps = max(0, next.manualJumps - 1)
        return next
    }

    /// Cost to raise `kind` by one level from the current state.
    public static func cost(of kind: UpgradeKind, in state: GameState) -> Double {
        kind.cost(atLevel: state.level(of: kind))
    }

    /// Total cost to buy `levels` of `kind`, or fewer if max level is reached.
    public static func bulkUpgradeCost(_ kind: UpgradeKind, levels: Int, in state: GameState) -> Double {
        guard levels > 0 else { return 0 }
        var total = 0.0
        var level = state.level(of: kind)
        for _ in 0..<levels {
            guard level < kind.levelCap else { break }
            total += kind.cost(atLevel: level)
            level += 1
        }
        return total
    }

    /// Maximum affordable levels of `kind` with current Peg Points.
    public static func maxAffordableLevels(_ kind: UpgradeKind, in state: GameState) -> Int {
        var remaining = state.pegPoints
        var level = state.level(of: kind)
        var count = 0
        while level < kind.levelCap {
            let price = kind.cost(atLevel: level)
            guard remaining >= price else { break }
            remaining -= price
            level += 1
            count += 1
        }
        return count
    }

    /// Buys one level of `kind`. Throws if funds are insufficient or at max level.
    public static func purchase(_ kind: UpgradeKind, in state: GameState) throws -> GameState {
        guard state.level(of: kind) < kind.levelCap else { throw PurchaseError.maxLevelReached }
        let price = cost(of: kind, in: state)
        guard state.pegPoints >= price else {
            throw PurchaseError.insufficientFunds(needed: price, have: state.pegPoints)
        }
        var next = state
        next.pegPoints -= price
        next.upgradeLevels[kind, default: 0] += 1
        return next
    }

    /// Buys up to `levels` of `kind`. Returns unchanged state if nothing affordable.
    public static func purchaseBulk(_ kind: UpgradeKind, levels: Int, in state: GameState) -> GameState {
        guard levels > 0 else { return state }
        var next = state
        for _ in 0..<levels {
            guard let purchased = try? purchase(kind, in: next) else { break }
            next = purchased
        }
        return next
    }

    // MARK: Prestige

    /// Lifetime jumps required to bank one prestige point (the resource that
    /// permanently raises the global multiplier).
    public static let jumpsPerPrestigePoint: Double = 500

    /// Each banked prestige point adds this much to the global multiplier.
    public static let prestigeMultiplierPerPoint: Double = 0.1

    /// Prestige points currently available to claim (beyond those already banked).
    /// Daily Puzzle progress (`dailyPrestigeJumps`) counts toward this alongside
    /// real lifetime jumps.
    public static func pendingPrestige(in state: GameState) -> Double {
        let progress = Double(state.totalPegsJumped) + state.dailyPrestigeJumps
        let earnable = (progress / jumpsPerPrestigePoint).squareRoot().rounded(.down)
        return max(0, earnable - state.prestigePointsClaimed)
    }

    /// Fraction toward the next prestige point (0…1).
    public static func prestigeProgressFraction(in state: GameState) -> Double {
        let progress = Double(state.totalPegsJumped) + state.dailyPrestigeJumps
        let earned = (progress / jumpsPerPrestigePoint).squareRoot().rounded(.down)
        let currentThreshold = earned * earned * jumpsPerPrestigePoint
        let nextThreshold = (earned + 1) * (earned + 1) * jumpsPerPrestigePoint
        guard nextThreshold > currentThreshold else { return 1 }
        return min(1, max(0, (progress - currentThreshold) / (nextThreshold - currentThreshold)))
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
        next.totalPrestiges += 1
        return next
    }

    // MARK: Board completion

    /// Per-streak-worthy-board bump to the completion bonus.
    public static let streakMultiplierStep: Double = 0.1

    /// Extra multiplier when the last peg lands on the board's center hole.
    public static let centerPegBonusMultiplier: Double = 1.5

    /// The outcome of a finished manual board, for the end-of-board tally.
    public struct BoardResult: Equatable, Sendable {
        public let pegsLeft: Int
        public let rank: BoardRank
        public let completionMultiplier: Double
        public let streakCount: Int
        public let streakMultiplier: Double
        public let bonusAwarded: Double
        public let boardEarnings: Double
        public let landedCenterPeg: Bool
        public let centerPegBonusMultiplier: Double
    }

    private static func updateBestRank(_ rank: BoardRank, pegsLeft: Int, in state: inout GameState) {
        let currentBest = state.bestRank.map { bestPegs(for: $0) } ?? Int.max
        if pegsLeft < currentBest { state.bestRank = rank }
    }

    private static func bestPegs(for rank: BoardRank) -> Int {
        switch rank {
        case .genius: return 1
        case .purtySmart: return 2
        case .justPlainDumb: return 3
        case .egNoRaMoose: return 4
        }
    }

    /// Settles a finished *manual* board: updates the streak and awards a
    /// completion bonus on top of the per-jump points already earned this run.
    ///
    /// - Parameters:
    ///   - pegsLeft: pegs remaining when the board ran out of moves.
    ///   - boardEarnings: Peg Points earned from jumps during this run (the base
    ///     the completion multiplier scales).
    public static func completeBoard(
        pegsLeft: Int,
        finalPeg: Position? = nil,
        boardLayout: BoardLayout = .classic,
        boardEarnings: Double,
        state: GameState
    ) -> (state: GameState, result: BoardResult) {
        let rank = BoardRank(pegsLeft: pegsLeft)
        let completionMult = rank.completionMultiplier(pegsLeft: pegsLeft)
        let landedCenter = pegsLeft == 1 && finalPeg == boardLayout.centerPosition
        let centerMult = landedCenter ? centerPegBonusMultiplier : 1.0

        var next = state
        next.streakCount = rank.isStreakWorthy ? state.streakCount + 1 : 0
        next.totalBoardsCompleted += 1
        updateBestRank(rank, pegsLeft: pegsLeft, in: &next)
        let streakMult = 1 + streakMultiplierStep * Double(next.streakCount)
        let bonus = max(0, boardEarnings * (completionMult - 1) * streakMult * centerMult)
        next.pegPoints += bonus
        recordEarnings(bonus, in: &next)

        return (
            next,
            BoardResult(
                pegsLeft: pegsLeft,
                rank: rank,
                completionMultiplier: completionMult,
                streakCount: next.streakCount,
                streakMultiplier: streakMult,
                bonusAwarded: bonus,
                boardEarnings: boardEarnings,
                landedCenterPeg: landedCenter,
                centerPegBonusMultiplier: centerMult
            )
        )
    }

    // MARK: Daily Puzzle

    /// Base prestige-jump reward for a daily solve, before rank/streak scaling.
    public static let dailyBasePrestigeJumps: Double = 100

    public struct DailyResult: Equatable, Sendable {
        public let dayNumber: Int
        public let rank: BoardRank
        public let dailyStreak: Int
        public let prestigeJumpsAwarded: Double
        public let alreadyClaimed: Bool
    }

    /// Claims today's Daily Puzzle reward (idempotent per day). Grants bonus
    /// prestige progress scaled by rank and the daily streak. Retrying a day
    /// already claimed returns the state unchanged with `alreadyClaimed = true`.
    public static func completeDaily(pegsLeft: Int, on date: Date, state: GameState) -> (state: GameState, result: DailyResult) {
        let today = DailyPuzzle.dayNumber(for: date)
        let rank = BoardRank(pegsLeft: pegsLeft)

        if state.lastDailyDay == today {
            return (state, DailyResult(dayNumber: today, rank: rank, dailyStreak: state.dailyStreak, prestigeJumpsAwarded: 0, alreadyClaimed: true))
        }

        var next = state
        next.dailyStreak = (state.lastDailyDay == today - 1) ? state.dailyStreak + 1 : 1
        next.lastDailyDay = today
        next.lastDailyRank = rank
        next.lastDailyPegsLeft = pegsLeft
        next.totalBoardsCompleted += 1
        updateBestRank(rank, pegsLeft: pegsLeft, in: &next)

        let base = dailyBasePrestigeJumps * rank.completionMultiplier(pegsLeft: pegsLeft)
        let streakBonus = 1 + 0.1 * Double(next.dailyStreak - 1)
        let award = base * streakBonus
        next.dailyPrestigeJumps += award

        return (
            next,
            DailyResult(dayNumber: today, rank: rank, dailyStreak: next.dailyStreak, prestigeJumpsAwarded: award, alreadyClaimed: false)
        )
    }

    /// The result of reconciling time the player spent away.
    public struct OfflineReport: Equatable, Sendable {
        public let jumps: Int
        public let pegPointsEarned: Double
        public let effectiveSeconds: Double
        public let wasCapped: Bool
        public let elapsedSeconds: Double
        public let capHours: Double
        public let jumpsPerSecond: Double

        public init(
            jumps: Int,
            pegPointsEarned: Double,
            effectiveSeconds: Double,
            wasCapped: Bool,
            elapsedSeconds: Double,
            capHours: Double,
            jumpsPerSecond: Double
        ) {
            self.jumps = jumps
            self.pegPointsEarned = pegPointsEarned
            self.effectiveSeconds = effectiveSeconds
            self.wasCapped = wasCapped
            self.elapsedSeconds = elapsedSeconds
            self.capHours = capHours
            self.jumpsPerSecond = jumpsPerSecond
        }
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
            return (
                next,
                OfflineReport(
                    jumps: 0,
                    pegPointsEarned: 0,
                    effectiveSeconds: effective,
                    wasCapped: elapsed > cap,
                    elapsedSeconds: elapsed,
                    capHours: state.offlineCapHours,
                    jumpsPerSecond: rate
                )
            )
        }

        let jumps = Int((rate * effective).rounded(.down))
        let earned = state.reward(forJumping: jumps)
        next.pegPoints += earned
        recordEarnings(earned, in: &next)
        next.totalPegsJumped += jumps

        return (
            next,
            OfflineReport(
                jumps: jumps,
                pegPointsEarned: earned,
                effectiveSeconds: effective,
                wasCapped: elapsed > cap,
                elapsedSeconds: elapsed,
                capHours: state.offlineCapHours,
                jumpsPerSecond: rate
            )
        )
    }
}
