import SwiftUI
import PegGameDomain

struct DailyResultSheet: View {
    @Environment(\.dismiss) private var dismiss
    let result: EconomyEngine.DailyResult

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                DecorativeEmoji(emoji: "📅")
                Text("Daily Puzzle complete!")
                    .font(.title2.weight(.bold))

                Text(result.rank.displayName)
                    .font(.title.weight(.heavy))
                    .foregroundStyle(Theme.Colors.accent)

                VStack(spacing: Theme.Spacing.sm) {
                    statRow("Streak", "Day \(result.dailyStreak)")
                    statRow("Prestige progress", "+\(NumberFormatting.compact(result.prestigeJumpsAwarded)) jumps")
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Theme.Spacing.md)
                .background(RoundedRectangle(cornerRadius: 12).fill(Theme.Colors.surface))

                Button("Nice") { dismiss() }
                    .buttonStyle(.brandedPrimary)
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
}
