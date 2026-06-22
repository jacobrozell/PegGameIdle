import Foundation

/// Finds winning paths for triangular peg solitaire (leave exactly one peg).
enum BoardSolver {
    private struct StateKey: Hashable {
        let layoutSize: Int
        let pegMask: UInt64

        init(board: Board) {
            layoutSize = board.layout.size
            var mask: UInt64 = 0
            for (index, position) in board.layout.allPositions.enumerated() {
                if board.hasPeg(at: position) {
                    mask |= 1 << UInt64(index)
                }
            }
            pegMask = mask
        }
    }

    /// True when some sequence of legal jumps from `board` leaves exactly one peg.
    static func hasWinningPath(from board: Board) -> Bool {
        var cache: [StateKey: Bool] = [:]
        return search(from: board, cache: &cache)
    }

    /// The first legal move (deterministic order) that stays on a winning path, if any.
    static func suggestedMove(on board: Board) -> Move? {
        guard board.pegCount > 1 else { return nil }
        var cache: [StateKey: Bool] = [:]
        let moves = board.legalMoves().sorted { $0.description < $1.description }
        return moves.first { move in
            guard let next = board.applying(move) else { return false }
            return search(from: next, cache: &cache)
        }
    }

    private static func search(from board: Board, cache: inout [StateKey: Bool]) -> Bool {
        let key = StateKey(board: board)
        if let cached = cache[key] { return cached }

        let result: Bool
        if board.pegCount == 1 {
            result = true
        } else if board.legalMoves().isEmpty {
            result = false
        } else {
            result = board.legalMoves().contains { move in
                guard let next = board.applying(move) else { return false }
                return search(from: next, cache: &cache)
            }
        }

        cache[key] = result
        return result
    }
}
