import Foundation

/// Pure presentation policy for adaptive layout, kept here (no SwiftUI imports)
/// so the predicates are unit-testable on CI without a simulator.
///
/// Key rule from the build checklist: decide phone-vs-pad with the **idiom**,
/// not the horizontal size class alone — a Pro Max in landscape reports a
/// regular width but is not an iPad and should stay single-column.
public enum AdaptiveLayout {
    public enum Idiom: Sendable { case phone, pad }

    /// True when the board and the side panel (daily/prestige/upgrades) should sit
    /// side by side. We reserve the two-column layout for iPad in landscape, where
    /// there is genuine horizontal room; everything else stacks and scrolls.
    public static func usesSideBySide(idiom: Idiom, isLandscape: Bool) -> Bool {
        idiom == .pad && isLandscape
    }
}
