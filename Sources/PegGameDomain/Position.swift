import Foundation

/// A hole in the triangular peg board, addressed by `row` and `col`.
///
/// The board is a triangle where row `r` contains `r + 1` holes, indexed
/// `0...r`. Row 0 is the single hole at the apex. This mirrors the physical
/// Cracker Barrel board (5 rows, 15 holes) but is generalized to any size.
public struct Position: Hashable, Sendable, Comparable, Codable {
    public let row: Int
    public let col: Int

    public init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }

    public static func < (lhs: Position, rhs: Position) -> Bool {
        (lhs.row, lhs.col) < (rhs.row, rhs.col)
    }
}

extension Position: CustomStringConvertible {
    public var description: String { "(\(row),\(col))" }
}
