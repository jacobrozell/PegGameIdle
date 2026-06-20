import SwiftUI
import PegGameDomain

/// The core journey screen: play the board, watch idle earnings, buy upgrades.
public struct GameView: View {
    @State private var viewModel: GameViewModel

    /// Drives the foreground Auto-Jumper. One tick per second.
    private let tick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    public init(repository: GameStateRepository) {
        _viewModel = State(initialValue: GameViewModel(repository: repository))
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                CurrencyHeader(viewModel: viewModel)
                BoardView(viewModel: viewModel)
                statusLine
                controls
                PrestigeRow(viewModel: viewModel)
                UpgradesSection(viewModel: viewModel)
            }
            .padding()
            .navigationTitle("Peg Game Idle")
            .onReceive(tick) { _ in viewModel.tickAutoJumper(seconds: 1) }
        }
        .alert("Welcome back!", isPresented: offlineBinding) {
            Button("Collect", action: viewModel.dismissOfflineReport)
        } message: {
            if let report = viewModel.offlineReport {
                Text("Your Auto-Jumper cleared \(report.jumps) pegs and banked \(Int(report.pegPointsEarned)) Peg Points while you were away.")
            }
        }
    }

    private var statusLine: some View {
        Group {
            if viewModel.didWin {
                Label("Solved! One peg left.", systemImage: "trophy.fill")
                    .foregroundStyle(.green)
            } else if viewModel.isBoardFinished {
                Label("No moves left — \(viewModel.pegsRemaining) pegs remain.", systemImage: "flag.checkered")
                    .foregroundStyle(.secondary)
            } else {
                Text("\(viewModel.pegsRemaining) pegs remaining")
                    .foregroundStyle(.secondary)
            }
        }
        .font(.headline)
        .accessibilityIdentifier("status-line")
    }

    private var controls: some View {
        Button {
            viewModel.resetBoard()
        } label: {
            Label("New Board", systemImage: "arrow.clockwise")
                .frame(maxWidth: .infinity, minHeight: Theme.Metrics.minTouchTarget)
        }
        .buttonStyle(.borderedProminent)
        .tint(Theme.Colors.accent)
        .accessibilityIdentifier("new-board-button")
    }

    private var offlineBinding: Binding<Bool> {
        Binding(
            get: { viewModel.offlineReport != nil },
            set: { if !$0 { viewModel.dismissOfflineReport() } }
        )
    }
}

private struct CurrencyHeader: View {
    let viewModel: GameViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Peg Points").font(.caption).foregroundStyle(.secondary)
                Text(viewModel.pegPointsText)
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .monospacedDigit()
                    .accessibilityIdentifier("peg-points-value")
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                if viewModel.prestigeMultiplier > 1 {
                    Label(viewModel.prestigeMultiplierText, systemImage: "star.circle.fill")
                        .font(.callout)
                        .foregroundStyle(.yellow)
                        .accessibilityLabel("Prestige multiplier \(viewModel.prestigeMultiplierText)")
                }
                if viewModel.autoJumpsPerSecond > 0 {
                    Label(String(format: "%.1f/s", viewModel.autoJumpsPerSecond), systemImage: "bolt.fill")
                        .font(.callout)
                        .foregroundStyle(Theme.Colors.accent)
                        .accessibilityLabel("Auto-Jumper at \(viewModel.autoJumpsPerSecond) jumps per second")
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

/// Prestige: bank pending points for a permanent multiplier, resetting Peg
/// Points and upgrades. Only shown once at least one point is available.
private struct PrestigeRow: View {
    let viewModel: GameViewModel
    @State private var confirming = false

    var body: some View {
        if viewModel.canPrestige {
            Button {
                confirming = true
            } label: {
                HStack {
                    Image(systemName: "star.circle.fill")
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Prestige for +\(viewModel.pendingPrestige) point\(viewModel.pendingPrestige == 1 ? "" : "s")")
                            .font(.subheadline.weight(.semibold))
                        Text("New multiplier \(viewModel.projectedMultiplierText) — resets Peg Points & upgrades")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .frame(minHeight: Theme.Metrics.minTouchTarget)
                .contentShape(Rectangle())
            }
            .buttonStyle(.bordered)
            .tint(.yellow)
            .accessibilityIdentifier("prestige-button")
            .accessibilityHint("Resets Peg Points and upgrades for a permanent earnings multiplier")
            .confirmationDialog("Prestige now?", isPresented: $confirming, titleVisibility: .visible) {
                Button("Prestige (\(viewModel.projectedMultiplierText))", role: .destructive) {
                    viewModel.prestige()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You'll permanently earn \(viewModel.projectedMultiplierText) Peg Points, but lose your current Peg Points and upgrade levels.")
            }
        }
    }
}
