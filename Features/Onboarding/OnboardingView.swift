import SwiftUI

struct OnboardingView: View {
    @Environment(GameViewModel.self) private var game
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var page = 0
    @ScaledMetric(relativeTo: .body) private var pageMinHeight = 280

    private let pages: [(icon: String, title: String, body: String)] = [
        ("🎯", "Jump pegs over neighbors", "Tap a peg, then tap an empty hole two spaces away. The jumped peg is removed."),
        ("💰", "Earn Peg Points", "Every jump earns Peg Points. Finish with fewer pegs left for a bigger completion bonus."),
        ("⭐", "Grow over time", "Buy upgrades, solve the Daily Puzzle, unlock awards, and Prestige for a permanent multiplier.")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                TabView(selection: $page) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, item in
                        pageContent(item)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(minHeight: pageMinHeight)

                HStack {
                    Button("Skip") {
                        finish()
                    }
                    .foregroundStyle(.secondary)

                    Spacer()

                    Button(page == pages.count - 1 ? "Get started" : "Next") {
                        advance()
                    }
                    .font(.headline)
                    .accessibilityIdentifier(page == pages.count - 1 ? A11yID.onboardingGetStarted : A11yID.onboardingNext)
                }
            }
            .padding(28)
        }
        .presentationDragIndicator(.visible)
    }

    private func pageContent(_ item: (icon: String, title: String, body: String)) -> some View {
        VStack(spacing: 16) {
            DecorativeEmoji(emoji: item.icon)
            Text(item.title)
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            Text(item.body)
                .font(dynamicTypeSize.usesLargeTypeLayout ? .body : .subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .combine)
    }

    private func advance() {
        if page < pages.count - 1 {
            page += 1
        } else {
            finish()
        }
    }

    private func finish() {
        game.markOnboardingSeen()
        dismiss()
    }
}
