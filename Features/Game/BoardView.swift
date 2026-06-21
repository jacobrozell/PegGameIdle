import SwiftUI
import PegGameDomain

/// Renders the triangular peg board with motion and routes input to the view model.
struct BoardView: View {
    @Environment(GameViewModel.self) private var game
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: Theme.Metrics.pegSpacing) {
            ForEach(0..<game.board.layout.size, id: \.self) { row in
                HStack(spacing: Theme.Metrics.pegSpacing) {
                    ForEach(0...row, id: \.self) { col in
                        holeView(Position(row: row, col: col))
                    }
                }
            }
        }
        .padding()
        .background { PegBackground() }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Peg board, \(game.pegsRemaining) pegs remaining")
    }

    @ViewBuilder
    private func holeView(_ position: Position) -> some View {
        let hasPeg = game.board.hasPeg(at: position)
        let isSelected = game.isSelected(position)
        let isTarget = game.isTarget(position)
        let isAnimatingFrom = game.animatingJump?.from == position
        let isAnimatingTo = game.animatingJump?.to == position
        let isShaking = game.shakePosition == position
        let dealDelay = dealDelay(for: position)

        Button {
            game.tap(position)
        } label: {
            Circle()
                .fill(fillColor(hasPeg: hasPeg, isSelected: isSelected, isTarget: isTarget, isAnimatingFrom: isAnimatingFrom))
                .overlay {
                    if isTarget && !isAnimatingTo {
                        Image(systemName: "arrow.down.to.line")
                            .imageScale(.small)
                            .foregroundStyle(.white)
                            .symbolEffect(.pulse, options: .repeating, value: isTarget)
                    } else if isSelected {
                        Circle().strokeBorder(.white, lineWidth: 3)
                    }
                }
                .frame(width: Theme.Metrics.pegDiameter, height: Theme.Metrics.pegDiameter)
                .scaleEffect(isSelected ? 1.08 : 1)
                .shadow(color: isSelected ? Theme.Colors.pegSelected.opacity(0.6) : .clear, radius: 6)
                .offset(x: isShaking ? 4 : 0)
                .opacity(isAnimatingFrom ? 0.3 : 1)
                .scaleEffect(isAnimatingTo ? 1.1 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(dragGesture(from: position))
        .accessibilityIdentifier("hole-\(position.row)-\(position.col)")
        .accessibilityLabel(accessibilityLabel(hasPeg: hasPeg, isSelected: isSelected, isTarget: isTarget))
        .accessibilityHint(hasPeg ? "Double-tap to select this peg" : isTarget ? "Double-tap to jump here" : "")
        .animation(.motionSafe(.easeOut(duration: 0.2), reduceMotion: reduceMotion), value: isSelected)
        .animation(.motionSafe(.easeInOut(duration: 0.08).repeatCount(3, autoreverses: true), reduceMotion: reduceMotion), value: isShaking)
        .modifier(DealAppearanceModifier(generation: game.boardDealGeneration, delay: dealDelay, reduceMotion: reduceMotion))
    }

    private func dragGesture(from position: Position) -> some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { _ in
                if !game.isSelected(position) { game.beginDrag(from: position) }
            }
            .onEnded { value in
                game.endDrag(from: position, translation: value.translation)
            }
    }

    private func fillColor(hasPeg: Bool, isSelected: Bool, isTarget: Bool, isAnimatingFrom: Bool) -> Color {
        if isAnimatingFrom { return Theme.Colors.holeEmpty }
        if isSelected { return Theme.Colors.pegSelected }
        if isTarget { return Theme.Colors.pegTarget }
        return hasPeg ? Theme.Colors.peg : Theme.Colors.holeEmpty
    }

    private func accessibilityLabel(hasPeg: Bool, isSelected: Bool, isTarget: Bool) -> String {
        if isSelected { return "Selected peg" }
        if isTarget { return "Empty landing hole" }
        return hasPeg ? "Peg" : "Empty hole"
    }

    private func dealDelay(for position: Position) -> Double {
        Double(position.row * 3 + position.col) * 0.03
    }
}

private struct DealAppearanceModifier: ViewModifier {
    let generation: Int
    let delay: Double
    let reduceMotion: Bool
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(appeared ? 1 : 0.5)
            .opacity(appeared ? 1 : 0)
            .onAppear { trigger() }
            .onChange(of: generation) { _, _ in trigger() }
    }

    private func trigger() {
        appeared = false
        if reduceMotion {
            appeared = true
            return
        }
        withAnimation(.easeOut(duration: 0.25).delay(delay)) {
            appeared = true
        }
    }
}
