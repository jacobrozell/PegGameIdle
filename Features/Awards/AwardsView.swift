import SwiftUI
import PegGameDomain

struct AwardsView: View {
    @Environment(GameViewModel.self) private var game

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground(showParticles: game.ambientParticlesEnabled)
                VStack(spacing: Theme.Spacing.sm) {
                    CurrencyHeader()
                    ScrollView {
                        VStack(spacing: Theme.Spacing.md) {
                            summaryLine
                            LazyVStack(spacing: Theme.Spacing.sm) {
                                ForEach(AchievementCatalog.all) { ach in
                                    AchievementRow(definition: ach, unlocked: game.isAchievementUnlocked(ach.achievementID))
                                }
                            }
                            StatsSection()
                        }
                        .padding(.horizontal)
                        .padding(.bottom, Theme.Spacing.md)
                    }
                }
            }
            .navigationTitle("Awards")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var summaryLine: some View {
        Text("\(game.state.unlockedAchievements.count)/\(AchievementCatalog.all.count) unlocked · +\(Int((game.state.achievementMultiplier - 1) * 100))% global")
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }
}

private struct AchievementRow: View {
    let definition: AchievementDefinition
    let unlocked: Bool

    var body: some View {
        Card(highlighted: unlocked, content: {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: Theme.Spacing.md) {
                    Image(systemName: unlocked ? definition.icon : "lock.fill")
                        .font(.title2)
                        .foregroundStyle(unlocked ? Theme.Colors.prestige : .secondary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(unlocked ? definition.title : "???")
                            .font(.subheadline.weight(.bold))
                        Text(unlocked ? definition.description : "Keep playing to unlock.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if unlocked {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(Theme.Colors.success)
                    }
                }
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: unlocked ? definition.icon : "lock.fill")
                        Text(unlocked ? definition.title : "???").font(.subheadline.weight(.bold))
                    }
                    Text(unlocked ? definition.description : "Keep playing to unlock.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
        })
        .opacity(unlocked ? 1 : 0.6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(unlocked ? "Unlocked: \(definition.title)" : "Locked award")
        .accessibilityIdentifier(A11yID.achievementRowPrefix + definition.achievementID.rawValue)
    }
}

struct StatsSection: View {
    @Environment(GameViewModel.self) private var game

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Lifetime Stats")
                .font(Theme.Typography.sectionTitle())
            Card(content: {
                VStack(spacing: Theme.Spacing.sm) {
                    statRow("Boards completed", "\(game.stats.totalBoardsCompleted)")
                    statRow("Best rank", game.stats.bestRank?.displayName ?? "—")
                    statRow("Lifetime Peg Points", NumberFormatting.compact(game.stats.lifetimePegPointsEarned))
                    statRow("Prestiges", "\(game.stats.totalPrestiges)")
                    statRow("Pegs jumped", "\(game.stats.totalPegsJumped)")
                }
                .font(.subheadline)
            })
        }
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value).fontWeight(.semibold).monospacedDigit()
        }
    }
}
