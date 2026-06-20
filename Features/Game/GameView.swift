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
            ScrollView {
                VStack(spacing: 24) {
                    CurrencyHeader(viewModel: viewModel)
                    BoardView(viewModel: viewModel)
                    statusLine
                    controls
                    DailyRow(viewModel: viewModel)
                    PrestigeRow(viewModel: viewModel)
                    UpgradesSection(viewModel: viewModel)
                }
                .padding()
            }
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
        .alert(boardResultTitle, isPresented: boardResultBinding) {
            Button("Play On", action: viewModel.dismissBoardResult)
        } message: {
            if let r = viewModel.lastBoardResult {
                Text(boardResultMessage(r))
            }
        }
        .alert("Daily Puzzle complete", isPresented: dailyResultBinding) {
            Button("Nice", action: viewModel.dismissDailyResult)
        } message: {
            if let r = viewModel.dailyResult {
                Text(dailyResultMessage(r))
            }
        }
    }

    private var statusLine: some View {
        Group {
            if viewModel.isDailyMode {
                Label("Daily Puzzle — solve it!", systemImage: "calendar")
                    .foregroundStyle(Theme.Colors.accent)
            } else if viewModel.streakCount > 1 {
                Label("\(viewModel.streakCount)× streak — \(viewModel.pegsRemaining) pegs left", systemImage: "flame.fill")
                    .foregroundStyle(.orange)
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
            viewModel.dealNormalBoard()
        } label: {
            Label("New Board", systemImage: "arrow.clockwise")
                .frame(maxWidth: .infinity, minHeight: Theme.Metrics.minTouchTarget)
        }
        .buttonStyle(.borderedProminent)
        .tint(Theme.Colors.accent)
        .accessibilityIdentifier("new-board-button")
    }

    // MARK: Alert plumbing

    private var boardResultTitle: String {
        viewModel.lastBoardResult.map(\.rank.displayName) ?? ""
    }

    private func boardResultMessage(_ r: EconomyEngine.BoardResult) -> String {
        let pegs = "\(r.pegsLeft) peg\(r.pegsLeft == 1 ? "" : "s") left"
        guard r.bonusAwarded > 0 else { return "\(pegs). No completion bonus — try to leave fewer!" }
        let streak = r.streakCount > 1 ? " (\(r.streakCount)× streak)" : ""
        return "\(pegs) — completion bonus +\(NumberFormatting.compact(r.bonusAwarded)) Peg Points\(streak)."
    }

    private func dailyResultMessage(_ r: EconomyEngine.DailyResult) -> String {
        "\(r.rank.displayName)! Day \(r.dailyStreak) streak — +\(NumberFormatting.compact(r.prestigeJumpsAwarded)) prestige progress."
    }

    private var offlineBinding: Binding<Bool> {
        Binding(
            get: { viewModel.offlineReport != nil },
            set: { if !$0 { viewModel.dismissOfflineReport() } }
        )
    }

    private var boardResultBinding: Binding<Bool> {
        Binding(
            get: { viewModel.lastBoardResult != nil },
            set: { if !$0 { viewModel.dismissBoardResult() } }
        )
    }

    private var dailyResultBinding: Binding<Bool> {
        Binding(
            get: { viewModel.dailyResult != nil },
            set: { if !$0 { viewModel.dismissDailyResult() } }
        )
    }
}

/// Daily Puzzle entry: a date-seeded board whose result accelerates prestige.
private struct DailyRow: View {
    let viewModel: GameViewModel

    var body: some View {
        Button {
            viewModel.startDailyPuzzle()
        } label: {
            HStack {
                Image(systemName: "calendar.badge.clock")
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Puzzle").font(.subheadline.weight(.semibold))
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
            }
            .frame(minHeight: Theme.Metrics.minTouchTarget)
            .contentShape(Rectangle())
        }
        .buttonStyle(.bordered)
        .disabled(viewModel.isDailyMode)
        .accessibilityIdentifier("daily-puzzle-button")
        .accessibilityHint("Plays today's seeded board for prestige progress")
    }

    private var subtitle: String {
        if viewModel.dailyClaimedToday {
            return "Claimed today · \(viewModel.dailyStreak)-day streak"
        }
        return viewModel.dailyStreak > 0 ? "\(viewModel.dailyStreak)-day streak — play today's board" : "Play today's board"
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
