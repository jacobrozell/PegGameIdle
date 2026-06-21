import SwiftUI
import PegGameDomain

struct BoardResultSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let result: EconomyEngine.BoardResult

    @State private var rankScale: CGFloat = 0.6

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                Text(result.rank.displayName)
                    .font(.largeTitle.weight(.heavy))
                    .foregroundStyle(Theme.Colors.accent)
                    .scaleEffect(rankScale)
                    .accessibilityAddTraits(.isHeader)

                Text("\(result.pegsLeft) peg\(result.pegsLeft == 1 ? "" : "s") left")
                    .font(.headline)

                VStack(spacing: Theme.Spacing.sm) {
                    statRow("Jump points", NumberFormatting.compact(result.boardEarnings))
                    statRow("Completion ×", String(format: "%.1f", result.completionMultiplier))
                    if result.streakCount > 1 {
                        statRow("Streak", "\(result.streakCount)× (×\(String(format: "%.1f", result.streakMultiplier)))")
                    }
                    statRow("Bonus earned", "+\(NumberFormatting.compact(result.bonusAwarded))")
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Theme.Spacing.md)
                .background(RoundedRectangle(cornerRadius: 12).fill(Theme.Colors.surface))

                Button("Play On") { dismiss() }
                    .buttonStyle(.brandedPrimary)
                    .accessibilityIdentifier(A11yID.boardResultPlayOn)
            }
            .padding(28)
        }
        .presentationDragIndicator(.visible)
        .onAppear {
            withAnimation(.motionSafe(.spring(duration: 0.45), reduceMotion: reduceMotion) ?? .default) {
                rankScale = 1
            }
        }
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value).monospacedDigit().fontWeight(.semibold)
        }
    }
}
