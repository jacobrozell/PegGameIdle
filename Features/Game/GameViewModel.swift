import Foundation
import CoreGraphics
import Observation
import PegGameDomain

/// Drives the core gameplay screen: the peg board plus live idle earnings.
///
/// All business rules live in `PegGameDomain`; this view model only translates
/// user intent into domain calls and exposes presentable state to SwiftUI.
@MainActor
@Observable
public final class GameViewModel {
    /// What the human board currently represents.
    public enum Mode: Equatable { case normal, daily }

    /// The board the player is interacting with.
    public private(set) var board: Board
    public private(set) var mode: Mode = .normal
    public private(set) var state: GameState

    /// The peg the player has tapped/grabbed first, awaiting a destination.
    public private(set) var selection: Position?
    /// Legal landing holes for the current selection (for highlighting).
    public private(set) var targets: Set<Position> = []

    /// One-shot summaries, shown then cleared by the view.
    public private(set) var offlineReport: EconomyEngine.OfflineReport?
    public private(set) var lastBoardResult: EconomyEngine.BoardResult?
    public private(set) var dailyResult: EconomyEngine.DailyResult?

    /// Peg Points earned from jumps during the current run — the base the
    /// completion multiplier scales at board end.
    private var currentBoardEarnings: Double = 0
    /// The Auto-Jumper's own board, separate from the human's run.
    private var autoBoard: Board

    private let repository: GameStateRepository
    private let autoPlayer = AutoPlayer(strategy: .greedy)
    private var rng = SystemRandomNumberGenerator()

    public init(repository: GameStateRepository, now: Date = .init()) {
        self.repository = repository
        let loaded = repository.load()
        let reconciled = EconomyEngine.reconcileOffline(now: now, state: loaded)
        self.state = reconciled.state
        self.board = Board(layout: .classic, empty: Position(row: 0, col: 0))
        self.autoBoard = Board(layout: .classic, empty: Position(row: 0, col: 0))
        self.offlineReport = reconciled.report.jumps > 0 ? reconciled.report : nil
        repository.save(reconciled.state)
    }

    // MARK: Presentation

    public var pegPoints: Double { state.pegPoints }
    public var pegPointsText: String { NumberFormatting.compact(state.pegPoints) }
    public var pegsRemaining: Int { board.pegCount }
    public var autoJumpsPerSecond: Double { state.autoJumpsPerSecond }
    public var isBoardFinished: Bool { board.isGameOver }
    public var didWin: Bool { board.isSolved }
    public var streakCount: Int { state.streakCount }
    public var isDailyMode: Bool { mode == .daily }

    // MARK: Prestige

    public var prestigeMultiplier: Double { state.prestigeMultiplier }
    public var prestigeMultiplierText: String { String(format: "%.1f×", state.prestigeMultiplier) }
    public var pendingPrestige: Int { Int(EconomyEngine.pendingPrestige(in: state)) }
    public var canPrestige: Bool { EconomyEngine.canPrestige(state) }
    public var projectedMultiplierText: String {
        String(format: "%.1f×", EconomyEngine.projectedMultiplier(after: state))
    }

    /// Banks pending prestige points and resets spendable progress + the board.
    public func prestige() {
        guard canPrestige else { return }
        state = EconomyEngine.prestige(state)
        dealNormalBoard()
        persist()
    }

    // MARK: Daily Puzzle

    public var dailyStreak: Int { state.dailyStreak }
    public var dailyClaimedToday: Bool {
        state.lastDailyDay == DailyPuzzle.dayNumber(for: Date())
    }

    /// Switches the human board to today's seeded Daily Puzzle.
    public func startDailyPuzzle(now: Date = .init()) {
        board = DailyPuzzle.board(for: now)
        mode = .daily
        currentBoardEarnings = 0
        clearSelection()
    }

    public func dismissDailyResult() { dailyResult = nil }

    // MARK: Selection / input

    public func isSelected(_ position: Position) -> Bool { selection == position }
    public func isTarget(_ position: Position) -> Bool { targets.contains(position) }

    /// Tap input (the accessible path): select a peg, deselect, or jump.
    public func tap(_ position: Position) {
        if let selected = selection {
            if position == selected {
                clearSelection()
            } else if let move = move(from: selected, to: position) {
                perform(move)
            } else {
                select(position)
            }
        } else {
            select(position)
        }
    }

    /// Drag input (the tactile path): grab a peg to preview its targets.
    public func beginDrag(from position: Position) {
        select(position)
    }

    /// Resolve a drag by matching its direction to the best legal jump from the
    /// grabbed peg. A drag that matches nothing leaves the peg selected (the
    /// targets stay highlighted so the player can tap instead).
    public func endDrag(from position: Position, translation: CGSize) {
        let candidates = board.legalMoves().filter { $0.from == position }
        guard !candidates.isEmpty else { clearSelection(); return }

        let drag = (x: Double(translation.width), y: Double(translation.height))
        let dragLen = (drag.x * drag.x + drag.y * drag.y).squareRoot()
        guard dragLen > 1 else { return } // a tap-like drag: keep selection

        func similarity(_ move: Move) -> Double {
            // Screen-space vector to the landing hole in our centered triangle:
            // x grows with column, shifts left half a step per row down.
            let vx = Double(move.to.col - move.from.col) - Double(move.to.row - move.from.row) / 2
            let vy = Double(move.to.row - move.from.row)
            let len = (vx * vx + vy * vy).squareRoot()
            guard len > 0 else { return -1 }
            return (drag.x * vx + drag.y * vy) / (dragLen * len)
        }

        if let best = candidates.max(by: { similarity($0) < similarity($1) }), similarity(best) > 0.4 {
            perform(best)
        }
    }

    private func select(_ position: Position) {
        guard board.hasPeg(at: position) else { clearSelection(); return }
        selection = position
        targets = Set(board.legalMoves().filter { $0.from == position }.map(\.to))
    }

    private func clearSelection() {
        selection = nil
        targets = []
    }

    private func move(from: Position, to: Position) -> Move? {
        board.legalMoves().first { $0.from == from && $0.to == to }
    }

    private func perform(_ move: Move) {
        let reward = state.reward(forJumping: 1)
        guard board.apply(move) else { return }
        state = EconomyEngine.awardJumps(1, to: state)
        currentBoardEarnings += reward
        clearSelection()
        settleIfFinished()
        persist()
    }

    /// Settles a run that just ran out of moves: pays the completion/daily
    /// reward, records the result for the tally UI, and auto-deals a new board.
    private func settleIfFinished() {
        guard board.isGameOver else { return }
        switch mode {
        case .normal:
            let outcome = EconomyEngine.completeBoard(
                pegsLeft: board.pegCount,
                boardEarnings: currentBoardEarnings,
                state: state
            )
            state = outcome.state
            lastBoardResult = outcome.result
        case .daily:
            let outcome = EconomyEngine.completeDaily(pegsLeft: board.pegCount, on: Date(), state: state)
            state = outcome.state
            dailyResult = outcome.result
        }
        dealNormalBoard()
    }

    // MARK: Auto-Jumper

    /// Advances the idle Auto-Jumper by `seconds`, on its own board (it never
    /// touches the human run). Offline time is handled in `init`.
    public func tickAutoJumper(seconds: Double) {
        let jumps = Int((state.autoJumpsPerSecond * seconds).rounded(.down))
        guard jumps > 0 else { return }
        var played = 0
        for _ in 0..<jumps {
            if autoBoard.isGameOver {
                autoBoard = Board(layout: .classic, empty: Position(row: 0, col: 0))
            }
            guard let move = autoPlayer.nextMove(on: autoBoard, using: &rng) else { break }
            autoBoard.apply(move)
            played += 1
        }
        if played > 0 {
            state = EconomyEngine.awardJumps(played, to: state) // floor income, no bonus
            persist()
        }
    }

    // MARK: Board management

    /// Deals a fresh normal board (used by auto-deal, prestige, and the manual
    /// New Board control). Abandoning a board this way earns no completion bonus.
    public func dealNormalBoard(empty: Position = Position(row: 0, col: 0)) {
        board = Board(layout: .classic, empty: empty)
        mode = .normal
        currentBoardEarnings = 0
        clearSelection()
    }

    public func dismissOfflineReport() { offlineReport = nil }
    public func dismissBoardResult() { lastBoardResult = nil }

    /// Wipes all saved progress (Phase 8.7: delete all local data) and starts
    /// the player over with a fresh board.
    public func resetAllProgress() {
        repository.reset()
        state = repository.load()
        currentBoardEarnings = 0
        offlineReport = nil
        lastBoardResult = nil
        dailyResult = nil
        dealNormalBoard()
    }

    // MARK: Upgrades

    public func purchase(_ kind: UpgradeKind) {
        guard let next = try? EconomyEngine.purchase(kind, in: state) else { return }
        state = next
        persist()
    }

    public func canAfford(_ kind: UpgradeKind) -> Bool {
        state.pegPoints >= EconomyEngine.cost(of: kind, in: state)
    }

    public func cost(of kind: UpgradeKind) -> Double { EconomyEngine.cost(of: kind, in: state) }

    private func persist() {
        var snapshot = state
        snapshot.lastSeen = Date()
        state.lastSeen = snapshot.lastSeen
        repository.save(snapshot)
    }
}
