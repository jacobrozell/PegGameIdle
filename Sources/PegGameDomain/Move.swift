import Foundation

/// A single peg jump: the `from` peg leaps over the `over` peg into the empty
/// `to` hole, removing the `over` peg from the board.
public struct Move: Hashable, Sendable, Codable {
    public let from: Position
    public let over: Position
    public let to: Position

    public init(from: Position, over: Position, to: Position) {
        self.from = from
        self.over = over
        self.to = to
    }
}

extension Move: CustomStringConvertible {
    public var description: String { "\(from) -> \(to) (x\(over))" }
}

/// The six straight-line jump directions on a triangular grid, expressed as the
/// offset to the jumped-over hole and the landing hole.
enum JumpDirection: CaseIterable {
    case left, right, upLeft, upRight, downLeft, downRight

    /// Offsets `(over, to)` relative to the jumping peg's `(row, col)`.
    var offsets: (over: (Int, Int), to: (Int, Int)) {
        switch self {
        case .left:      return ((0, -1), (0, -2))
        case .right:     return ((0, +1), (0, +2))
        case .upLeft:    return ((-1, -1), (-2, -2))
        case .upRight:   return ((-1, 0), (-2, 0))
        case .downLeft:  return ((+1, 0), (+2, 0))
        case .downRight: return ((+1, +1), (+2, +2))
        }
    }
}
