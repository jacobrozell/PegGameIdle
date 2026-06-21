import SwiftUI

/// Subtle gradient behind the peg board.
struct PegBackground: View {
    @Environment(\.themePalette) private var theme

    var body: some View {
        RoundedRectangle(cornerRadius: Theme.Metrics.cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        theme.boardPrimary.opacity(0.95),
                        theme.boardSecondary.opacity(0.85),
                        theme.boardShadow
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: Theme.Metrics.cornerRadius, style: .continuous)
                    .stroke(Color.black.opacity(0.15), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
    }
}

/// App-wide gradient background.
struct AppBackground: View {
    var showParticles: Bool
    @Environment(\.themePalette) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        theme.background
            .overlay {
                LinearGradient(
                    colors: [theme.background, theme.backgroundGradientEnd],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .overlay {
                if showParticles && !reduceMotion {
                    AmbientParticlesView()
                }
            }
            .ignoresSafeArea()
    }
}

/// Subtle drifting peg silhouettes.
struct AmbientParticlesView: View {
    @Environment(\.themePalette) private var theme
    private let count = 10

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<count, id: \.self) { i in
                    AmbientParticle(index: i, area: geo.size, pegColor: theme.peg)
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct AmbientParticle: View {
    let index: Int
    let area: CGSize
    let pegColor: Color
    @State private var falling = false

    private func rand(_ salt: Int) -> Double {
        let v = (index * 9301 + salt * 49297 + 233) % 233280
        return Double(v) / 233280.0
    }

    var body: some View {
        let startX = rand(1) * area.width
        let drift = (rand(2) - 0.5) * 60
        let size = 8 + rand(3) * 10
        let duration = 10 + rand(4) * 8
        let delay = rand(5) * 6

        Circle()
            .fill(pegColor.opacity(0.15))
            .frame(width: size, height: size)
            .position(
                x: startX + (falling ? drift : 0),
                y: falling ? area.height + 40 : -40
            )
            .onAppear {
                withAnimation(
                    .linear(duration: duration)
                        .repeatForever(autoreverses: false)
                        .delay(delay)
                ) { falling = true }
            }
    }
}
