import SwiftUI

/// Brief full-screen sparkle burst after prestiging (respects Reduce Motion).
struct PrestigeCelebrationView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: Theme.Spacing.lg) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(Theme.Colors.prestige)
                    .symbolEffect(.bounce, options: reduceMotion ? .nonRepeating : .repeating, value: reduceMotion)

                Text("Prestiged!")
                    .font(.title.weight(.heavy))
                    .foregroundStyle(.white)
            }
            .padding(Theme.Spacing.xxl)
            .background(
                RoundedRectangle(cornerRadius: Theme.Metrics.cornerRadius, style: .continuous)
                    .fill(Theme.Colors.surfaceElevated.opacity(0.95))
            )
            .shadow(radius: 24)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Prestige complete")
        .allowsHitTesting(false)
    }
}
