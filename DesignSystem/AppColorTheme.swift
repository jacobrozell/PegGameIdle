import SwiftUI

/// Built-in color themes. Generic peg-game palettes — not tied to any restaurant brand.
public enum AppColorTheme: String, CaseIterable, Identifiable, Codable {
    case slate
    case forest
    case ocean
    case sunset

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .slate: return "Slate"
        case .forest: return "Forest"
        case .ocean: return "Ocean"
        case .sunset: return "Sunset"
        }
    }

    public var subtitle: String {
        switch self {
        case .slate: return "Cool gray & teal"
        case .forest: return "Moss & emerald"
        case .ocean: return "Deep blue & cyan"
        case .sunset: return "Plum & rose"
        }
    }

    public var palette: ThemePalette {
        switch self {
        case .slate: return .slate
        case .forest: return .forest
        case .ocean: return .ocean
        case .sunset: return .sunset
        }
    }
}

/// Semantic colors for one theme (light + dark adaptive where noted).
public struct ThemePalette: Equatable {
    let background: Color
    let surface: Color
    let surfaceElevated: Color
    let backgroundGradientEnd: Color

    let boardPrimary: Color
    let boardSecondary: Color
    let boardShadow: Color

    let holeEmpty: Color
    let peg: Color
    let pegSelected: Color
    let pegTarget: Color

    let accent: Color
    let currency: Color
    let prestige: Color
    let success: Color
    let warning: Color

    let cardStroke: Color
    let cardHighlight: Color
    let primaryButtonForeground: Color

    private static func adaptive(light: UIColor, dark: UIColor) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }

    public static let slate = ThemePalette(
        background: adaptive(
            light: UIColor(red: 0.95, green: 0.96, blue: 0.97, alpha: 1),
            dark: UIColor(red: 0.06, green: 0.07, blue: 0.09, alpha: 1)
        ),
        surface: adaptive(
            light: UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1),
            dark: UIColor(red: 0.11, green: 0.12, blue: 0.15, alpha: 1)
        ),
        surfaceElevated: adaptive(
            light: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1),
            dark: UIColor(red: 0.16, green: 0.17, blue: 0.21, alpha: 1)
        ),
        backgroundGradientEnd: adaptive(
            light: UIColor(red: 0.90, green: 0.92, blue: 0.95, alpha: 1),
            dark: UIColor(red: 0.10, green: 0.12, blue: 0.16, alpha: 1)
        ),
        boardPrimary: Color(red: 0.35, green: 0.40, blue: 0.48),
        boardSecondary: Color(red: 0.28, green: 0.33, blue: 0.40),
        boardShadow: Color(red: 0.18, green: 0.22, blue: 0.28),
        holeEmpty: adaptive(
            light: UIColor.systemGray4,
            dark: UIColor(red: 0.22, green: 0.25, blue: 0.30, alpha: 1)
        ),
        peg: Color(red: 0.88, green: 0.48, blue: 0.42),
        pegSelected: Color(red: 0.99, green: 0.78, blue: 0.45),
        pegTarget: Color(red: 0.20, green: 0.70, blue: 0.62).opacity(0.65),
        accent: Color(red: 0.05, green: 0.58, blue: 0.53),
        currency: Color(red: 0.85, green: 0.47, blue: 0.02),
        prestige: Color(red: 0.98, green: 0.82, blue: 0.25),
        success: Color(red: 0.13, green: 0.70, blue: 0.42),
        warning: Color(red: 0.92, green: 0.60, blue: 0.08),
        cardStroke: Color.white.opacity(0.08),
        cardHighlight: Color(red: 0.05, green: 0.58, blue: 0.53).opacity(0.85),
        primaryButtonForeground: Color(red: 0.04, green: 0.12, blue: 0.11)
    )

    public static let forest = ThemePalette(
        background: adaptive(
            light: UIColor(red: 0.94, green: 0.96, blue: 0.94, alpha: 1),
            dark: UIColor(red: 0.05, green: 0.09, blue: 0.06, alpha: 1)
        ),
        surface: adaptive(
            light: UIColor(red: 0.97, green: 0.99, blue: 0.97, alpha: 1),
            dark: UIColor(red: 0.10, green: 0.14, blue: 0.11, alpha: 1)
        ),
        surfaceElevated: adaptive(
            light: UIColor(red: 1.0, green: 1.0, blue: 0.99, alpha: 1),
            dark: UIColor(red: 0.14, green: 0.19, blue: 0.15, alpha: 1)
        ),
        backgroundGradientEnd: adaptive(
            light: UIColor(red: 0.86, green: 0.92, blue: 0.86, alpha: 1),
            dark: UIColor(red: 0.08, green: 0.13, blue: 0.09, alpha: 1)
        ),
        boardPrimary: Color(red: 0.30, green: 0.42, blue: 0.32),
        boardSecondary: Color(red: 0.24, green: 0.34, blue: 0.26),
        boardShadow: Color(red: 0.14, green: 0.22, blue: 0.16),
        holeEmpty: adaptive(
            light: UIColor(red: 0.78, green: 0.84, blue: 0.78, alpha: 1),
            dark: UIColor(red: 0.18, green: 0.24, blue: 0.19, alpha: 1)
        ),
        peg: Color(red: 0.79, green: 0.54, blue: 0.02),
        pegSelected: Color(red: 0.98, green: 0.86, blue: 0.35),
        pegTarget: Color(red: 0.02, green: 0.59, blue: 0.41).opacity(0.60),
        accent: Color(red: 0.02, green: 0.59, blue: 0.41),
        currency: Color(red: 0.79, green: 0.54, blue: 0.02),
        prestige: Color(red: 0.92, green: 0.78, blue: 0.20),
        success: Color(red: 0.13, green: 0.65, blue: 0.38),
        warning: Color(red: 0.85, green: 0.55, blue: 0.10),
        cardStroke: Color.white.opacity(0.08),
        cardHighlight: Color(red: 0.02, green: 0.59, blue: 0.41).opacity(0.85),
        primaryButtonForeground: Color(red: 0.03, green: 0.10, blue: 0.07)
    )

    public static let ocean = ThemePalette(
        background: adaptive(
            light: UIColor(red: 0.94, green: 0.97, blue: 1.0, alpha: 1),
            dark: UIColor(red: 0.04, green: 0.09, blue: 0.16, alpha: 1)
        ),
        surface: adaptive(
            light: UIColor(red: 0.97, green: 0.99, blue: 1.0, alpha: 1),
            dark: UIColor(red: 0.08, green: 0.14, blue: 0.22, alpha: 1)
        ),
        surfaceElevated: adaptive(
            light: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1),
            dark: UIColor(red: 0.12, green: 0.20, blue: 0.30, alpha: 1)
        ),
        backgroundGradientEnd: adaptive(
            light: UIColor(red: 0.86, green: 0.93, blue: 0.98, alpha: 1),
            dark: UIColor(red: 0.06, green: 0.12, blue: 0.20, alpha: 1)
        ),
        boardPrimary: Color(red: 0.12, green: 0.35, blue: 0.52),
        boardSecondary: Color(red: 0.10, green: 0.28, blue: 0.42),
        boardShadow: Color(red: 0.06, green: 0.18, blue: 0.28),
        holeEmpty: adaptive(
            light: UIColor(red: 0.72, green: 0.82, blue: 0.90, alpha: 1),
            dark: UIColor(red: 0.14, green: 0.22, blue: 0.32, alpha: 1)
        ),
        peg: Color(red: 0.71, green: 0.82, blue: 0.92),
        pegSelected: Color(red: 0.55, green: 0.88, blue: 0.98),
        pegTarget: Color(red: 0.02, green: 0.52, blue: 0.78).opacity(0.65),
        accent: Color(red: 0.01, green: 0.52, blue: 0.78),
        currency: Color(red: 0.20, green: 0.65, blue: 0.88),
        prestige: Color(red: 0.55, green: 0.88, blue: 0.98),
        success: Color(red: 0.12, green: 0.68, blue: 0.55),
        warning: Color(red: 0.95, green: 0.65, blue: 0.15),
        cardStroke: Color.white.opacity(0.08),
        cardHighlight: Color(red: 0.01, green: 0.52, blue: 0.78).opacity(0.85),
        primaryButtonForeground: Color(red: 0.02, green: 0.08, blue: 0.14)
    )

    public static let sunset = ThemePalette(
        background: adaptive(
            light: UIColor(red: 0.98, green: 0.96, blue: 0.99, alpha: 1),
            dark: UIColor(red: 0.09, green: 0.06, blue: 0.12, alpha: 1)
        ),
        surface: adaptive(
            light: UIColor(red: 0.99, green: 0.97, blue: 1.0, alpha: 1),
            dark: UIColor(red: 0.14, green: 0.10, blue: 0.18, alpha: 1)
        ),
        surfaceElevated: adaptive(
            light: UIColor(red: 1.0, green: 0.99, blue: 1.0, alpha: 1),
            dark: UIColor(red: 0.20, green: 0.14, blue: 0.24, alpha: 1)
        ),
        backgroundGradientEnd: adaptive(
            light: UIColor(red: 0.93, green: 0.88, blue: 0.96, alpha: 1),
            dark: UIColor(red: 0.12, green: 0.08, blue: 0.16, alpha: 1)
        ),
        boardPrimary: Color(red: 0.42, green: 0.32, blue: 0.50),
        boardSecondary: Color(red: 0.34, green: 0.26, blue: 0.42),
        boardShadow: Color(red: 0.22, green: 0.16, blue: 0.30),
        holeEmpty: adaptive(
            light: UIColor(red: 0.84, green: 0.78, blue: 0.88, alpha: 1),
            dark: UIColor(red: 0.26, green: 0.20, blue: 0.30, alpha: 1)
        ),
        peg: Color(red: 0.98, green: 0.45, blue: 0.55),
        pegSelected: Color(red: 0.99, green: 0.72, blue: 0.55),
        pegTarget: Color(red: 0.75, green: 0.15, blue: 0.65).opacity(0.60),
        accent: Color(red: 0.75, green: 0.15, blue: 0.65),
        currency: Color(red: 0.95, green: 0.45, blue: 0.55),
        prestige: Color(red: 0.99, green: 0.72, blue: 0.35),
        success: Color(red: 0.45, green: 0.72, blue: 0.35),
        warning: Color(red: 0.95, green: 0.55, blue: 0.20),
        cardStroke: Color.white.opacity(0.08),
        cardHighlight: Color(red: 0.75, green: 0.15, blue: 0.65).opacity(0.85),
        primaryButtonForeground: Color(red: 0.12, green: 0.04, blue: 0.10)
    )
}

private struct ThemePaletteKey: EnvironmentKey {
    static let defaultValue = ThemePalette.slate
}

extension EnvironmentValues {
    public var themePalette: ThemePalette {
        get { self[ThemePaletteKey.self] }
        set { self[ThemePaletteKey.self] = newValue }
    }
}
