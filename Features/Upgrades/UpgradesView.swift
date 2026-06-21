import SwiftUI
import PegGameDomain

struct UpgradesView: View {
    @Environment(GameViewModel.self) private var game
    @Environment(\.themePalette) private var theme

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground(showParticles: game.ambientParticlesEnabled)
                VStack(spacing: Theme.Spacing.sm) {
                    CurrencyHeader()
                    ScrollView {
                        LazyVStack(spacing: Theme.Spacing.md) {
                            ForEach(UpgradeKind.allCases, id: \.self) { kind in
                                UpgradeRow(kind: kind)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, Theme.Spacing.md)
                    }
                }
            }
            .navigationTitle("Upgrades")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct UpgradeRow: View {
    @Environment(GameViewModel.self) private var game
    @Environment(\.themePalette) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let kind: UpgradeKind

    @State private var purchasePulse = false

    private static let descriptionMinHeight: CGFloat = 34
    private static let effectMinHeight: CGFloat = 18
    private static let actionRowHeight: CGFloat = Theme.Metrics.minTouchTarget

    var body: some View {
        let level = game.level(of: kind)
        let maxed = game.isMaxLevel(kind)
        let afford1 = game.canAfford(kind)

        Card(highlighted: afford1 && !maxed, content: {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                HStack(spacing: Theme.Spacing.md) {
                    Image(systemName: kind.icon)
                        .font(.title2)
                        .foregroundStyle(theme.accent)
                        .frame(width: 32, height: 32)

                    Text(kind.displayName)
                        .font(.subheadline.weight(.bold))
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    levelBadge(level: level, maxed: maxed)
                }

                Text(kind.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, minHeight: Self.descriptionMinHeight, alignment: .topLeading)

                effectLine(level: level, maxed: maxed)
                    .frame(maxWidth: .infinity, minHeight: Self.effectMinHeight, alignment: .leading)

                actionRow(maxed: maxed)
                    .frame(maxWidth: .infinity, minHeight: Self.actionRowHeight, alignment: .center)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        })
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.upgradeRowPrefix + kind.rawValue)
        .scaleEffect(purchasePulse ? 1.02 : 1)
        .animation(.motionSafe(.spring(duration: 0.25), reduceMotion: reduceMotion), value: purchasePulse)
    }

    @ViewBuilder
    private func levelBadge(level: Int, maxed: Bool) -> some View {
        Text(maxed ? "MAX" : "Lv \(level)")
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Capsule().fill(maxed ? theme.success.opacity(0.2) : theme.surface))
            .foregroundStyle(maxed ? theme.success : .secondary)
    }

    @ViewBuilder
    private func effectLine(level: Int, maxed: Bool) -> some View {
        if maxed {
            Text(game.effectDescription(for: kind))
                .font(.caption.monospacedDigit())
                .foregroundStyle(theme.success)
                .lineLimit(2)
        } else if let next = game.nextEffectDescription(for: kind) {
            Text("\(game.effectDescription(for: kind)) → \(next)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        } else {
            Text(" ")
                .font(.caption)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    private func actionRow(maxed: Bool) -> some View {
        if maxed {
            HStack {
                Spacer()
                Label("Fully upgraded", systemImage: "checkmark.seal.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.success)
                Spacer()
            }
        } else {
            HStack(spacing: Theme.Spacing.sm) {
                buyButton("×1", levels: 1)
                buyButton("×10", levels: 10)
                buyButton("Max", levels: game.maxAffordable(for: kind))
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func buyButton(_ label: String, levels: Int) -> some View {
        let cost = game.bulkCost(of: kind, levels: levels)
        let enabled = levels > 0 && game.pegPoints >= cost && !game.isMaxLevel(kind)
        return Button {
            game.purchase(kind, levels: levels)
            triggerPurchasePulse()
        } label: {
            VStack(spacing: 2) {
                Text(label).font(.caption.weight(.bold))
                Text("\(NumberFormatting.compact(cost)) PP")
                    .font(.caption2.monospacedDigit())
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity, minHeight: Self.actionRowHeight)
            .padding(.horizontal, 4)
            .background(RoundedRectangle(cornerRadius: 8).fill(enabled ? theme.accent.opacity(0.15) : theme.surface))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .accessibilityIdentifier(A11yID.upgradeBuyPrefix + kind.rawValue + "-\(levels)")
        .accessibilityLabel("\(label) buy \(kind.displayName) for \(Int(cost)) Peg Points")
    }

    private func triggerPurchasePulse() {
        purchasePulse = true
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(280))
            purchasePulse = false
        }
    }
}
