import Foundation
import Observation
import PegGameDomain

/// Drives the core gameplay screen: the peg board plus live idle earnings.
///
/// All business rules live in `PegGameDomain`; this view model only translates
/// user intent into domain calls and exposes presentable state to SwiftUI.
@MainActor
@Observable
public final class GameViewModel {
    public private(set) var board: Board
    public private(set) var state: GameState

    /// The peg the player has tapped first, awaiting a destination.
    public private(set) var selection: Position?
    /// Legal landing holes for the current selection (for highlighting).
    public private(set) var targets: Set<Position> = []
    /// One-shot "welcome back" summary, shown then cleared by the view.
    public private(set) var offlineReport: EconomyEngine.OfflineReport?

    private let repository: GameStateRepository
    private let autoPlayer = AutoPlayer(strategy: .greedy)
    private var rng = SystemRandomNumberGenerator()

    public init(repository: GameStateRepository, now: Date = .init()) {
        self.repository = repository
        let loaded = repository.load()
        let reconciled = EconomyEngine.reconcileOffline(now: now, state: loaded)
        self.state = reconciled.state
        self.board = Board(layout: .classic, empty: Position(row: 0, col: 0))
        self.offlineReport = reconciled.report.jumps > 0 ? reconciled.report : nil
        repository.save(reconciled.state)
    }

    public var pegPoints: Double { state.pegPoints }
    public var pegPointsText: String { NumberFormatting.compact(state.pegPoints) }
    public var pegsRemaining: Int { board.pegCount }
    public var autoJumpsPerSecond: Double { state.autoJumpsPerSecond }
    public var isBoardFinished: Bool { board.isGameOver }
    public var didWin: Bool { board.isSolved }

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
        resetBoard()
        persist()
    }

    public func isSelected(_ position: Position) -> Bool { selection == position }
    public func isTarget(_ position: Position) -> Bool { targets.contains(position) }

    /// Handles a tap on a hole: select a peg, deselect, or perform a jump.
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
        guard board.apply(move) else { return }
        state = EconomyEngine.awardJumps(1, to: state)
        clearSelection()
        persist()
    }

    /// Advances the idle Auto-Jumper by `seconds` of real time. Called from a
    /// foreground timer; offline time is handled in `init` via reconciliation.
    public func tickAutoJumper(seconds: Double) {
        let jumps = Int((state.autoJumpsPerSecond * seconds).rounded(.down))
        guard jumps > 0 else { return }
        var played = 0
        for _ in 0..<jumps {
            guard let move = autoPlayer.nextMove(on: board, using: &rng) else { break }
            board.apply(move)
            played += 1
        }
        if played > 0 {
            state = EconomyEngine.awardJumps(played, to: state)
            persist()
        }
    }

    /// Starts a fresh board, keeping all idle progress.
    public func resetBoard(empty: Position = Position(row: 0, col: 0)) {
        board = Board(layout: .classic, empty: empty)
        clearSelection()
    }

    public func dismissOfflineReport() { offlineReport = nil }

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
