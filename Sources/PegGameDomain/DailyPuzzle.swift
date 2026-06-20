import Foundation

/// Generates the once-per-day seeded board. Deterministic from the date so the
/// same calendar day yields the same board everywhere — no backend required.
public enum DailyPuzzle {

    /// UTC day number: whole days since the Unix epoch. Doubles as the streak key.
    public static func dayNumber(for date: Date) -> Int {
        Int((date.timeIntervalSince1970 / 86_400).rounded(.down))
    }

    /// A stable seed for the day.
    public static func seed(for date: Date) -> UInt64 {
        // Mix the day number so consecutive days don't produce adjacent boards.
        var x = UInt64(bitPattern: Int64(dayNumber(for: date)))
        x = (x &+ 0x9E3779B97F4A7C15)
        x = (x ^ (x >> 30)) &* 0xBF58476D1CE4E5B9
        x = (x ^ (x >> 27)) &* 0x94D049BB133111EB
        return x ^ (x >> 31)
    }

    /// The board to play for `date`: classic 15-hole layout with the single
    /// empty hole chosen deterministically from the seed.
    public static func board(for date: Date, layout: BoardLayout = .classic) -> Board {
        var rng = SplitMix64(seed: seed(for: date))
        let positions = layout.allPositions
        let empty = positions[Int(rng.next() % UInt64(positions.count))]
        return Board(layout: layout, empty: empty)
    }
}

/// Small, fast, seedable PRNG so daily boards are reproducible in tests.
struct SplitMix64: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
