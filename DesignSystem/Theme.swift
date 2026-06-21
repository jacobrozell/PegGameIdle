import SwiftUI

/// Non-color design tokens. Semantic colors live in `ThemePalette` / `@Environment(\.themePalette)`.
public enum Theme {
    public enum Typography {
        public static func currencyLarge() -> Font {
            .system(.largeTitle, design: .rounded).weight(.bold)
        }
        public static func statLabel() -> Font { .caption2.weight(.semibold) }
        public static func statValue() -> Font {
            .system(.subheadline, design: .rounded).weight(.bold)
        }
        public static func sectionTitle() -> Font { .headline }
    }

    public enum Spacing {
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 12
        public static let lg: CGFloat = 16
        public static let xl: CGFloat = 24
        public static let xxl: CGFloat = 32
    }

    public enum Metrics {
        /// Minimum interactive target per WCAG 2.5.5 / Apple HIG.
        public static let minTouchTarget: CGFloat = 44
        public static let pegDiameter: CGFloat = 44
        public static let pegSpacing: CGFloat = 12
        public static let cornerRadius: CGFloat = 16
        public static let cardRadius: CGFloat = 14
        public static let cardShadowRadius: CGFloat = 6
    }
}
