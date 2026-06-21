import SwiftUI
import UIKit
import PegGameDomain

/// Play tab: board, status, prestige meter, and New Board control.
struct PlayView: View {
    @Environment(GameViewModel.self) private var game
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

    private var statusLine: some View {
        Group {
            if game.isDailyMode {
                Label("Daily Puzzle — solve it!", systemImage: "calendar")
                    .foregroundStyle(Theme.Colors.accent)
            } else if game.streakCount > 1 {
                Label("\(game.streakCount)× streak — \(game.pegsRemaining) pegs left", systemImage: "flame.fill")
                    .foregroundStyle(.orange)
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
            Label("New Board", systemImage: "arrow.clockwise")
        }
        .buttonStyle(.brandedPrimary)
        .accessibilityIdentifier(A11yID.newBoard)
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
