import SwiftUI
import UIKit
import PegGameDomain

/// Play tab: board, status, prestige meter, and New Board control.
struct PlayView: View {
    @Environment(GameViewModel.self) private var game
    @Environment(\.themePalette) private var theme
    @Binding var showSettings: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground(showParticles: game.ambientParticlesEnabled)
                GeometryReader { proxy in
                    let idiom: AdaptiveLayout.Idiom =
                        UIDevice.current.userInterfaceIdiom == .pad ? .pad : .phone
                    let isLandscape = proxy.size.width > proxy.size.height

                    if AdaptiveLayout.usesSideBySide(idiom: idiom, isLandscape: isLandscape) {
                        sideBySideLayout
                    } else {
                        stackedLayout
                    }
                }
            }
            .navigationTitle("Play")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                    .accessibilityIdentifier(A11yID.settingsButton)
                }
            }
        }
    }

    private var stackedLayout: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                CurrencyHeader()
                BoardView()
                gameplayControls
                statusLine
                PrestigeMeter()
                if game.canPrestige {
                    prestigeButton
                }
                newBoardButton
            }
            .padding()
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
        }
    }

    private var sideBySideLayout: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.xxl) {
            VStack(spacing: Theme.Spacing.lg) {
                CurrencyHeader()
                BoardView()
                gameplayControls
                statusLine
                newBoardButton
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: Theme.Spacing.lg) {
                PrestigeMeter()
                if game.canPrestige { prestigeButton }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(Theme.Spacing.xl)
    }

    private var gameplayControls: some View {
        HStack(spacing: Theme.Spacing.md) {
            Button {
                game.undoLastMove()
            } label: {
                Label("Undo", systemImage: "arrow.uturn.backward")
                    .frame(maxWidth: .infinity, minHeight: Theme.Metrics.minTouchTarget)
            }
            .disabled(!game.canUndo)
            .opacity(game.canUndo ? 1 : 0.35)
            .accessibilityIdentifier(A11yID.undoButton)

            Button {
                game.showHint()
            } label: {
                Label("Hint", systemImage: "lightbulb")
                    .frame(maxWidth: .infinity, minHeight: Theme.Metrics.minTouchTarget)
            }
            .disabled(!game.canHint)
            .opacity(game.canHint ? 1 : 0.35)
            .accessibilityIdentifier(A11yID.hintButton)

            if game.hasActiveHint {
                Button {
                    game.clearHint()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .frame(width: Theme.Metrics.minTouchTarget, height: Theme.Metrics.minTouchTarget)
                }
                .accessibilityLabel("Clear hint")
                .accessibilityIdentifier(A11yID.clearHintButton)
            }
        }
        .buttonStyle(.plain)
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(theme.accent)
    }

    private var statusLine: some View {
        Group {
            if game.isDailyMode {
                Label("Daily Puzzle — solve it!", systemImage: "calendar")
                    .foregroundStyle(theme.accent)
            } else if !game.board.layout.displayName.isEmpty && game.board.layout.size > 5 {
                Label("\(game.boardLayoutName) · \(game.pegsRemaining) pegs left", systemImage: "square.grid.3x3")
                    .foregroundStyle(.secondary)
            } else if game.streakCount > 1 {
                Label("\(game.streakCount)× streak — \(game.pegsRemaining) pegs left", systemImage: "flame.fill")
                    .foregroundStyle(theme.warning)
            } else {
                Text("\(game.pegsRemaining) pegs remaining")
                    .foregroundStyle(.secondary)
            }
        }
        .font(.headline)
        .accessibilityIdentifier(A11yID.statusLine)
    }

    private var newBoardButton: some View {
        Button {
            game.dealNormalBoard()
        } label: {
            Label(
                game.isDailyMode ? "Exit Daily" : "New Board",
                systemImage: game.isDailyMode ? "xmark.circle" : "arrow.clockwise"
            )
        }
        .buttonStyle(.brandedPrimary)
        .accessibilityIdentifier(A11yID.newBoard)
        .accessibilityLabel(game.isDailyMode ? "Exit daily puzzle" : "New board")
    }

    private var prestigeButton: some View {
        Button {
            game.showPrestigeSheet()
        } label: {
            Label("Prestige for +\(game.pendingPrestige)", systemImage: "star.circle.fill")
        }
        .buttonStyle(.brandedSecondary)
        .accessibilityIdentifier(A11yID.prestigeButton)
    }
}
