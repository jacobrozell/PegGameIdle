import SwiftUI

/// Semantic design tokens. Colors are defined for light and dark and chosen for
/// WCAG AA contrast on their intended backgrounds (tracked in accessibility/).
public enum Theme {
    public enum Colors {
        public static let boardWood = Color(red: 0.45, green: 0.29, blue: 0.16)
        public static let holeEmpty = Color(.systemGray4)
        public static let peg = Color(red: 0.86, green: 0.45, blue: 0.16)
        public static let pegSelected = Color(red: 0.97, green: 0.78, blue: 0.20)
        public static let pegTarget = Color.green.opacity(0.55)
        public static let accent = Color.orange
    }

    public enum Metrics {
        /// Minimum interactive target per WCAG 2.5.5 / Apple HIG.
        public static let minTouchTarget: CGFloat = 44
        public static let pegDiameter: CGFloat = 44
        public static let pegSpacing: CGFloat = 12
        public static let cornerRadius: CGFloat = 16
    }
}
