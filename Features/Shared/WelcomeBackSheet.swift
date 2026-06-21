import SwiftUI
import PegGameDomain

struct WelcomeBackSheet: View {
    @Environment(\.themePalette) private var theme
    @Environment(\.dismiss) private var dismiss
    let report: EconomyEngine.OfflineReport

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                DecorativeEmoji(emoji: "🪵")
                Text("Welcome back!")
                    .font(.title2.weight(.bold))
                    .accessibilityAddTraits(.isHeader)

                Text("Your Auto-Jumper kept playing while you were away.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Text("+\(NumberFormatting.compact(report.pegPointsEarned)) Peg Points")
                    .font(.largeTitle.weight(.heavy))
                    .foregroundStyle(theme.currency)

                breakdown
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(breakdownLabel)

                if report.wasCapped {
                    Text("Offline Reserve filled — upgrade it to bank more away time.")
                        .font(.caption)
                        .foregroundStyle(theme.warning)
                        .multilineTextAlignment(.center)
                }

                Button("Collect") { dismiss() }
                    .buttonStyle(.brandedPrimary)
                    .accessibilityIdentifier(A11yID.welcomeBackCollect)
            }
            .padding(28)
        }
        .presentationDragIndicator(.visible)
    }

    private var breakdown: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            row("Away", formatDuration(report.elapsedSeconds))
            row("Counted", formatDuration(report.effectiveSeconds))
            row("Rate", String(format: "%.1f jumps/s", report.jumpsPerSecond))
            row("Jumps", "\(report.jumps)")
            row("Cap", "\(Int(report.capHours)) hours")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.md)
        .background(RoundedRectangle(cornerRadius: 12).fill(theme.surface))
    }

    private var breakdownLabel: String {
        "Away \(formatDuration(report.elapsedSeconds)). Counted \(formatDuration(report.effectiveSeconds)). \(report.jumps) jumps at \(String(format: "%.1f", report.jumpsPerSecond)) per second."
    }

    private func row(_ label: String, _ value: String) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack { Text(label).frame(minWidth: 80, alignment: .leading); Text(value) }
            VStack(alignment: .leading) { Text(label).fontWeight(.medium); Text(value) }
        }
    }

    private func formatDuration(_ seconds: Double) -> String {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        if m > 0 { return "\(m)m" }
        return "\(Int(seconds))s"
    }
}
