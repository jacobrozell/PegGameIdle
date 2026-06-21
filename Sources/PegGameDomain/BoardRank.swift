import Foundation

/// End-of-board grade from pegs remaining. Maps count to a label and completion multiplier.
public enum BoardRank: String, CaseIterable, Sendable, Codable {
    case genius
    case purtySmart
    case justPlainDumb
    case egNoRaMoose

    public init(pegsLeft: Int) {
        switch pegsLeft {
        case ...1: self = .genius
        case 2:    self = .purtySmart
        case 3:    self = .justPlainDumb
        default:   self = .egNoRaMoose
        }
    }

    public var displayName: String {
        switch self {
        case .genius:        return "Expert"
        case .purtySmart:    return "Sharp"
        case .justPlainDumb: return "Fair"
        case .egNoRaMoose:   return "Rough"
        }
    }

    /// Multiplier applied to the run's accumulated jump points at board end.
    /// `egNoRaMoose` is rank-dependent: exactly 4 left earns a small bonus,
    /// 5+ earns none (×1) — the "forgone bonus" for a sloppy board.
    public func completionMultiplier(pegsLeft: Int) -> Double {
        switch self {
        case .genius:        return 5.0
        case .purtySmart:    return 3.0
        case .justPlainDumb: return 2.0
        case .egNoRaMoose:   return pegsLeft == 4 ? 1.25 : 1.0
        }
    }

    /// True for finishes good enough to extend a streak (genius / purty smart).
    public var isStreakWorthy: Bool {
        self == .genius || self == .purtySmart
    }
}
