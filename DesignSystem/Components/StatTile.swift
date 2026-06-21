import SwiftUI

/// Label + monospaced value tile (BloomScroll StatsBar pattern).
struct StatTile: View {
    @Environment(\.themePalette) private var theme
    let label: String
    let value: String
    var tint: Color?
    var accessibilityID: String?

    var body: some View {
        let accent = tint ?? theme.accent
        VStack(spacing: 1) {
            Text(label.uppercased())
                .font(Theme.Typography.statLabel())
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Text(value)
                .font(Theme.Typography.statValue())
                .foregroundStyle(accent)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(RoundedRectangle(cornerRadius: 10).fill(theme.surface))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(value)
        .accessibilityIdentifier(accessibilityID ?? "")
    }
}
