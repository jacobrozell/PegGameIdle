import SwiftUI

enum BrandedButtonStyle {
    case primary
    case secondary
    case destructive
}

struct BrandedButton: ButtonStyle {
    @Environment(\.themePalette) private var theme
    var style: BrandedButtonStyle = .primary
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: Theme.Metrics.minTouchTarget)
            .padding(.horizontal, Theme.Spacing.lg)
            .background { backgroundShape(configuration: configuration) }
            .foregroundStyle(foreground)
            .opacity(isEnabled ? 1 : 0.45)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    private var foreground: Color {
        switch style {
        case .primary: return theme.primaryButtonForeground
        case .secondary: return theme.accent
        case .destructive: return .white
        }
    }

    @ViewBuilder
    private func backgroundShape(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        switch style {
        case .primary:
            Capsule().fill(theme.accent.opacity(pressed ? 0.85 : 1))
        case .secondary:
            Capsule().strokeBorder(theme.accent, lineWidth: 2)
                .background(Capsule().fill(theme.surface.opacity(pressed ? 0.7 : 1)))
        case .destructive:
            Capsule().fill(Color.red.opacity(pressed ? 0.85 : 1))
        }
    }
}

extension ButtonStyle where Self == BrandedButton {
    static var brandedPrimary: BrandedButton { BrandedButton(style: .primary) }
    static var brandedSecondary: BrandedButton { BrandedButton(style: .secondary) }
    static var brandedDestructive: BrandedButton { BrandedButton(style: .destructive) }
}
