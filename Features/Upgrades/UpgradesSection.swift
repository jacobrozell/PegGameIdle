import SwiftUI
import PegGameDomain

/// The shop: repeatable upgrades that spend Peg Points. Kept on the core screen
/// for v1 so the idle loop (earn → spend → earn faster) is visible at a glance.
struct UpgradesSection: View {
    let viewModel: GameViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Upgrades")
                .font(.headline)
            ForEach(UpgradeKind.allCases, id: \.self) { kind in
                UpgradeRow(kind: kind, viewModel: viewModel)
            }
        }
        .accessibilityElement(children: .contain)
    }
}

private struct UpgradeRow: View {
    let kind: UpgradeKind
    let viewModel: GameViewModel

    var body: some View {
        Button {
            viewModel.purchase(kind)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(kind.displayName).font(.subheadline.weight(.semibold))
                    Text(kind.detail).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(Int(viewModel.cost(of: kind))) PP")
                    .font(.callout.monospacedDigit())
                    .foregroundStyle(viewModel.canAfford(kind) ? Theme.Colors.accent : .secondary)
            }
            .frame(minHeight: Theme.Metrics.minTouchTarget)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!viewModel.canAfford(kind))
        .accessibilityIdentifier("upgrade-\(kind.rawValue)")
        .accessibilityLabel("\(kind.displayName), costs \(Int(viewModel.cost(of: kind))) Peg Points")
        .accessibilityHint(viewModel.canAfford(kind) ? "Double-tap to buy" : "Not enough Peg Points")
    }
}
