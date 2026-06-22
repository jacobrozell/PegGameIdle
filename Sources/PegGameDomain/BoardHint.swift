import Foundation

/// Suggests a legal move on a path to a perfect solve (one peg left), when one exists.
public enum BoardHint {
    public static func suggestedMove(on board: Board) -> Move? {
        BoardSolver.suggestedMove(on: board)
    }
}
