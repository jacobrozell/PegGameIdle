import SwiftUI

struct PrestigeSheet: View {
    @Environment(GameViewModel.self) private var game
    @Environment(\.themePalette) private var theme
    @Environment(\.dismiss) private var dismiss
    let presentation: PrestigePresentation

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                DecorativeEmoji(emoji: "⭐")
                Text("Prestige now?")
                    .font(.title2.weight(.bold))

                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    statRow("Bank", "\(presentation.pendingPoints) prestige point\(presentation.pendingPoints == 1 ? "" : "s")")
                    statRow("Multiplier", "\(fmt(presentation.currentMultiplier)) → \(fmt(presentation.projectedMultiplier))")
                    Text("Resets: Peg Points and upgrade levels")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Keeps: lifetime jumps, daily streak, awards")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Theme.Spacing.md)
                .background(RoundedRectangle(cornerRadius: 12).fill(theme.surface))

                Button("Prestige (\(fmt(presentation.projectedMultiplier)))") {
                    game.prestige()
                    dismiss()
                }
                .buttonStyle(.brandedPrimary)

                Button("Cancel", role: .cancel) { dismiss() }
                    .buttonStyle(.brandedSecondary)
            }
            .padding(28)
        }
        .presentationDragIndicator(.visible)
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value).fontWeight(.semibold)
        }
    }

    private func fmt(_ value: Double) -> String { String(format: "%.2f×", value) }
}
