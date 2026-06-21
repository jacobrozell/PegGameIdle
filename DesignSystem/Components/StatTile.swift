import SwiftUI

/// Label + monospaced value tile (BloomScroll StatsBar pattern).
struct StatTile: View {
    let label: String
    let value: String
    var tint: Color = Theme.Colors.accent
    var accessibilityID: String?

    var body: some View {
        VStack(spacing: 1) {
            Text(label.uppercased())
                .font(Theme.Typography.statLabel())
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Text(value)
                .font(Theme.Typography.statValue())
                .foregroundStyle(tint)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(RoundedRectangle(cornerRadius: 10).fill(Theme.Colors.surface))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(value)
        .accessibilityIdentifier(accessibilityID ?? "")
    }
}
