import SwiftUI

/// Semantic design tokens. Colors adapt to light/dark and are chosen for
/// WCAG AA contrast on their intended backgrounds.
public enum Theme {
    public enum Colors {
        public static let background = Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.08, green: 0.06, blue: 0.05, alpha: 1)
                : UIColor(red: 0.96, green: 0.92, blue: 0.86, alpha: 1)
        })
        public static let surface = Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.14, green: 0.12, blue: 0.10, alpha: 1)
                : UIColor(red: 0.98, green: 0.96, blue: 0.93, alpha: 1)
        })
        public static let surfaceElevated = Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.20, green: 0.17, blue: 0.14, alpha: 1)
                : UIColor(red: 1.0, green: 0.99, blue: 0.97, alpha: 1)
        })
        public static let boardWood = Color(red: 0.45, green: 0.29, blue: 0.16)
        public static let holeEmpty = Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.28, green: 0.24, blue: 0.20, alpha: 1)
                : UIColor.systemGray4
        })
        public static let peg = Color(red: 0.86, green: 0.45, blue: 0.16)
        public static let pegSelected = Color(red: 0.97, green: 0.78, blue: 0.20)
        public static let pegTarget = Color.green.opacity(0.55)
        public static let accent = Color.orange
        public static let currency = Color(red: 0.95, green: 0.55, blue: 0.15)
        public static let prestige = Color.yellow
        public static let success = Color.green
        public static let warning = Color(red: 0.95, green: 0.65, blue: 0.20)
        public static let cardStroke = Color.white.opacity(0.08)
        public static let cardHighlight = Color.green.opacity(0.85)
    }

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
