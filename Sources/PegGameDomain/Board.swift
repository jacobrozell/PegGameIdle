import Foundation

/// The mutable state of a peg-solitaire board: which holes currently hold pegs.
///
/// `Board` is pure value-type domain logic with no UI or persistence
/// dependencies. It enforces the rules of triangular peg solitaire.
public struct Board: Equatable, Sendable, Codable {
    public let layout: BoardLayout
    public private(set) var pegs: Set<Position>

    public init(layout: BoardLayout, pegs: Set<Position>) {
        self.layout = layout
        self.pegs = pegs
    }

    /// A fresh board with every hole filled except `empty`.
    public init(layout: BoardLayout = .classic, empty: Position = Position(row: 0, col: 0)) {
        precondition(layout.contains(empty), "Empty hole must be on the board")
        self.layout = layout
        self.pegs = Set(layout.allPositions).subtracting([empty])
    }

    public var pegCount: Int { pegs.count }

    public func hasPeg(at position: Position) -> Bool { pegs.contains(position) }

    /// True once no further jumps are possible.
    public var isGameOver: Bool { legalMoves().isEmpty }

    /// True when the puzzle is solved: exactly one peg remains.
    public var isSolved: Bool { pegCount == 1 }

    /// Every legal jump from the current state.
    public func legalMoves() -> [Move] {
        var moves: [Move] = []
        for from in pegs {
            for direction in JumpDirection.allCases {
                let (overOffset, toOffset) = direction.offsets
                let over = Position(row: from.row + overOffset.0, col: from.col + overOffset.1)
                let to = Position(row: from.row + toOffset.0, col: from.col + toOffset.1)
                guard layout.contains(to), !pegs.contains(to), pegs.contains(over) else { continue }
                moves.append(Move(from: from, over: over, to: to))
            }
        }
        return moves
    }

    public func isLegal(_ move: Move) -> Bool {
        pegs.contains(move.from)
            && pegs.contains(move.over)
            && layout.contains(move.to)
            && !pegs.contains(move.to)
            && isAdjacentJump(move)
    }

    private func isAdjacentJump(_ move: Move) -> Bool {
        JumpDirection.allCases.contains { direction in
            let (overOffset, toOffset) = direction.offsets
            return move.over == Position(row: move.from.row + overOffset.0, col: move.from.col + overOffset.1)
                && move.to == Position(row: move.from.row + toOffset.0, col: move.from.col + toOffset.1)
        }
    }

    /// Applies `move`, removing the jumped peg. Returns `false` if illegal.
    @discardableResult
    public mutating func apply(_ move: Move) -> Bool {
        guard isLegal(move) else { return false }
        pegs.remove(move.from)
        pegs.remove(move.over)
        pegs.insert(move.to)
        return true
    }

    public func applying(_ move: Move) -> Board? {
        var copy = self
        return copy.apply(move) ? copy : nil
    }
}
