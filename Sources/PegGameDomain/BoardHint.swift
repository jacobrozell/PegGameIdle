import Foundation

/// Suggests a legal move for the human player (greedy strategy, deterministic).
public enum BoardHint {
    public static func suggestedMove(on board: Board) -> Move? {
        var rng = SystemRandomNumberGenerator()
        return AutoPlayer(strategy: .greedy).nextMove(on: board, using: &rng)
    }
}
