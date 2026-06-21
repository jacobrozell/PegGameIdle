import Foundation

/// Single registry for every external URL the app links to. Centralized so the
/// store listing, settings, and onboarding never hard-code scattered strings.
///
/// The hosted pages don't exist yet — they're created and published via GitHub
/// Pages in Phase 15. URLs use the repository's canonical casing.
public enum AppLinks {
    private static let pagesBase = "https://jacobrozell.github.io/PegGameIdle"

    public static let privacy = URL(string: "\(pagesBase)/privacy.html")!
    public static let support = URL(string: "\(pagesBase)/support.html")!
    public static let accessibility = URL(string: "\(pagesBase)/accessibility.html")!

    /// Optional tip/donate link. `nil` hides the row entirely (owner decision:
    /// no tip jar in 1.0).
    public static let tipJar: URL? = nil
}
