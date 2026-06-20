import Foundation

/// Chooses jumps automatically — the engine behind the idle "Auto-Jumper".
///
/// The player is deterministic given a seed so behavior is reproducible in
/// tests and so offline progress is replayable. It is intentionally simple:
/// the idle loop only needs *a* legal move, while the human player chases the
/// optimal solve.
public struct AutoPlayer {
    /// Strategy for picking among legal moves.
    public enum Strategy {
        /// Pick a legal move pseudo-randomly (deterministic via the RNG).
        case random
        /// Prefer moves that keep the most future options open.
        case greedy
    }

    public let strategy: Strategy

    public init(strategy: Strategy = .greedy) {
        self.strategy = strategy
    }

    /// Returns the next move to play, or `nil` if the board is finished.
    public func nextMove(on board: Board, using rng: inout some RandomNumberGenerator) -> Move? {
        let moves = board.legalMoves()
        guard !moves.isEmpty else { return nil }

        switch strategy {
        case .random:
            return moves.randomElement(using: &rng)
        case .greedy:
            // Pick the move whose resulting board has the most legal follow-ups,
            // breaking ties deterministically by move ordering.
            return moves.max { lhs, rhs in
                let lhsScore = board.applying(lhs)?.legalMoves().count ?? -1
                let rhsScore = board.applying(rhs)?.legalMoves().count ?? -1
                if lhsScore != rhsScore { return lhsScore < rhsScore }
                return moveOrder(lhs) > moveOrder(rhs)
            }
        }
    }

    private func moveOrder(_ move: Move) -> String { move.description }

    /// Plays the board to completion, returning the sequence of jumps taken.
    public func playOut(_ board: Board, using rng: inout some RandomNumberGenerator) -> [Move] {
        var current = board
        var moves: [Move] = []
        while let move = nextMove(on: current, using: &rng) {
            current.apply(move)
            moves.append(move)
        }
        return moves
    }
}
