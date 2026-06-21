import SwiftUI
import PegGameDomain

struct CurrencyHeader: View {
    @Environment(GameViewModel.self) private var game
    @Environment(\.themePalette) private var theme
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var isCompactHeight: Bool { verticalSizeClass == .compact }
    private let gridColumns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ViewThatFits(in: .horizontal) {
            statsRow
            ViewThatFits(in: .horizontal) {
                statsGrid
                statsStack
            }
        }
        .padding(.horizontal)
        .padding(.vertical, isCompactHeight ? 4 : 8)
        .frame(maxWidth: .infinity)
    }

    private var statsRow: some View {
        HStack(spacing: isCompactHeight ? 6 : 10) {
            pegPointsTile
            if game.autoJumpsPerSecond > 0 {
                StatTile(label: "Auto", value: String(format: "%.1f/s", game.autoJumpsPerSecond), tint: theme.accent)
            }
            if game.prestigeMultiplier > 1 || game.state.achievementMultiplier > 1 {
                StatTile(label: "Global", value: game.globalMultiplierText, tint: theme.prestige)
            }
        }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 8) {
            pegPointsTile
            if game.autoJumpsPerSecond > 0 {
                StatTile(label: "Auto", value: String(format: "%.1f/s", game.autoJumpsPerSecond), tint: theme.accent)
            }
            if game.prestigeMultiplier > 1 || game.state.achievementMultiplier > 1 {
                StatTile(label: "Global", value: game.globalMultiplierText, tint: theme.prestige)
            }
        }
    }

    private var statsStack: some View {
        VStack(spacing: 8) {
            pegPointsTile
            if game.autoJumpsPerSecond > 0 {
                StatTile(label: "Auto", value: String(format: "%.1f/s", game.autoJumpsPerSecond), tint: theme.accent)
            }
            if game.prestigeMultiplier > 1 || game.state.achievementMultiplier > 1 {
                StatTile(label: "Global", value: game.globalMultiplierText, tint: theme.prestige)
            }
        }
    }

    private var pegPointsTile: some View {
        StatTile(
            label: "Peg Points",
            value: game.pegPointsText,
            tint: theme.currency,
            accessibilityID: A11yID.pegPoints
        )
    }
}

struct PrestigeMeter: View {
    @Environment(GameViewModel.self) private var game
    @Environment(\.themePalette) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Label("Prestige", systemImage: "star.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.prestige)
                Spacer()
                if game.canPrestige {
                    Text("\(game.pendingPrestige) ready")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(theme.success)
                } else {
                    Text("\(Int(game.prestigeProgressFraction * 100))%")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            ProgressView(value: game.canPrestige ? 1 : game.prestigeProgressFraction)
                .tint(theme.prestige)
        }
        .padding(Theme.Spacing.md)
        .background(theme.surface, in: RoundedRectangle(cornerRadius: Theme.Metrics.cardRadius))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(A11yID.prestigeMeter)
        .accessibilityLabel(prestigeAccessibilityLabel)
    }

    private var prestigeAccessibilityLabel: String {
        if game.canPrestige {
            return "Prestige ready, \(game.pendingPrestige) points available"
        }
        return "Prestige progress \(Int(game.prestigeProgressFraction * 100)) percent"
    }
}
