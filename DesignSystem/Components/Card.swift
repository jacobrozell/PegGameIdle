import SwiftUI

/// Card container used by shop rows and panels.
struct Card<Content: View>: View {
    @Environment(\.themePalette) private var theme
    var highlighted = false
    @ViewBuilder var content: () -> Content
    @ScaledMetric(relativeTo: .body) private var padding = 12

    var body: some View {
        content()
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: Theme.Metrics.cardRadius, style: .continuous)
                    .fill(theme.surfaceElevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Metrics.cardRadius, style: .continuous)
                    .stroke(
                        highlighted ? theme.cardHighlight : theme.cardStroke,
                        lineWidth: highlighted ? 1.5 : 1
                    )
            )
            .shadow(color: .black.opacity(0.12), radius: Theme.Metrics.cardShadowRadius, y: 2)
    }
}
