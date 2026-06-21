import SwiftUI

/// Subtle gradient behind the peg board.
struct PegBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: Theme.Metrics.cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Theme.Colors.boardWood.opacity(0.95),
                        Theme.Colors.boardWood.opacity(0.75),
                        Color(red: 0.35, green: 0.22, blue: 0.12)
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

/// App-wide warm wood gradient background.
struct AppBackground: View {
    var showParticles: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Theme.Colors.background
            .overlay {
                LinearGradient(
                    colors: [
                        Theme.Colors.background,
                        Color(uiColor: UIColor { $0.userInterfaceStyle == .dark
                            ? UIColor(red: 0.12, green: 0.10, blue: 0.08, alpha: 1)
                            : UIColor(red: 0.92, green: 0.86, blue: 0.78, alpha: 1) })
                    ],
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
    private let count = 10

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<count, id: \.self) { i in
                    AmbientParticle(index: i, area: geo.size)
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
            .fill(Theme.Colors.peg.opacity(0.15))
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
