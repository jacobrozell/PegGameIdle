import SwiftUI

extension DynamicTypeSize {
    /// True at AX1 and larger content sizes.
    var usesAccessibleLayout: Bool { self >= .accessibility1 }

    /// True at XX Large and above — includes all accessibility sizes.
    var usesLargeTypeLayout: Bool { self >= .xxLarge }
}

extension EnvironmentValues {
    var usesAccessibleLayout: Bool { dynamicTypeSize.usesAccessibleLayout }
    var usesLargeTypeLayout: Bool { dynamicTypeSize.usesLargeTypeLayout }
}

extension Animation {
    /// Returns `nil` when Reduce Motion is on so callers can skip implicit animations.
    static func motionSafe(_ animation: Animation, reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : animation
    }
}

/// Decorative emoji that scales with Dynamic Type but stays out of VoiceOver.
struct DecorativeEmoji: View {
    let emoji: String
    @ScaledMetric(relativeTo: .largeTitle) private var size = 56

    var body: some View {
        Text(emoji)
            .font(.system(size: size))
            .accessibilityHidden(true)
    }
}
