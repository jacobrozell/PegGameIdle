import Foundation

/// The geometry of a triangular peg board, independent of which holes are filled.
///
/// `size` is the number of rows. The classic board is `size: 5` (15 holes).
/// (15 holes). Larger sizes are used by the idle game's board-upgrade tiers.
public struct BoardLayout: Equatable, Sendable, Codable {
    public let size: Int

    public init(size: Int) {
        precondition(size >= 1, "Board must have at least one row")
        self.size = size
    }

    /// Total number of holes: the triangular number of `size`.
    public var holeCount: Int { size * (size + 1) / 2 }

    /// True when `position` is a real hole on this board.
    public func contains(_ position: Position) -> Bool {
        position.row >= 0
            && position.row < size
            && position.col >= 0
            && position.col <= position.row
    }

    /// Every hole on the board, in row-major order.
    public var allPositions: [Position] {
        (0..<size).flatMap { row in
            (0...row).map { Position(row: row, col: $0) }
        }
    }

    public static let classic = BoardLayout(size: 5)

    /// Traditional ideal finishing hole — center of the bottom row.
    public var centerPosition: Position {
        Position(row: size - 1, col: (size - 1) / 2)
    }

    public var displayName: String {
        size == 5 ? "Classic" : "\(holeCount)-hole"
    }
}
