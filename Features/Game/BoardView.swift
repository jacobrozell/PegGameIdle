import SwiftUI
import PegGameDomain

/// Renders the triangular peg board with motion and routes input to the view model.
struct BoardView: View {
    @Environment(GameViewModel.self) private var game
    @Environment(\.themePalette) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var pegDiameter: CGFloat {
        min(Theme.Metrics.pegDiameter, Theme.Metrics.pegDiameter * 5 / CGFloat(game.board.layout.size))
    }

    private var pegSpacing: CGFloat {
        min(Theme.Metrics.pegSpacing, Theme.Metrics.pegSpacing * 5 / CGFloat(game.board.layout.size))
    }

    var body: some View {
        VStack(spacing: pegSpacing) {
            ForEach(0..<game.board.layout.size, id: \.self) { row in
                HStack(spacing: pegSpacing) {
                    ForEach(0...row, id: \.self) { col in
                        holeView(Position(row: row, col: col))
                    }
                }
            }
        }
        .padding()
        .background { PegBackground() }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(game.boardLayoutName) board, \(game.pegsRemaining) pegs remaining")
    }

    @ViewBuilder
    private func holeView(_ position: Position) -> some View {
        let hasPeg = game.board.hasPeg(at: position)
        let isSelected = game.isSelected(position)
        let isTarget = game.isTarget(position)
        let isAnimatingFrom = game.animatingJump?.from == position
        let isAnimatingTo = game.animatingJump?.to == position
        let isShaking = game.shakePosition == position
        let isHintFrom = game.hintMove?.from == position
        let isHintTo = game.hintMove?.to == position
        let isCenterGoal = !game.isDailyMode && position == game.board.layout.centerPosition
        let dealDelay = dealDelay(for: position)

        Button {
            game.tap(position)
        } label: {
            Circle()
                .fill(fillColor(
                    hasPeg: hasPeg,
                    isSelected: isSelected,
                    isTarget: isTarget,
                    isHintFrom: isHintFrom,
                    isHintTo: isHintTo,
                    isAnimatingFrom: isAnimatingFrom
                ))
                .overlay {
                    if isHintFrom && hasPeg {
                        Image(systemName: "star.fill")
                            .imageScale(.small)
                            .foregroundStyle(theme.prestige)
                    } else if isHintTo && !hasPeg {
                        Image(systemName: "lightbulb.fill")
                            .imageScale(.small)
                            .foregroundStyle(theme.warning)
                            .symbolEffect(.pulse, options: .repeating, value: isHintTo)
                    } else if isTarget && !isAnimatingTo {
                        Image(systemName: "arrow.down.to.line")
                            .imageScale(.small)
                            .foregroundStyle(.white)
                            .symbolEffect(.pulse, options: .repeating, value: isTarget)
                    } else if isSelected {
                        Circle().strokeBorder(.white, lineWidth: 3)
                    } else if isCenterGoal {
                        Circle().strokeBorder(theme.prestige.opacity(0.35), lineWidth: 2)
                    }
                }
                .frame(width: pegDiameter, height: pegDiameter)
                .scaleEffect(isSelected ? 1.08 : 1)
                .shadow(color: isSelected ? theme.pegSelected.opacity(0.6) : .clear, radius: 6)
                .offset(x: isShaking ? 4 : 0)
                .opacity(isAnimatingFrom ? 0.3 : 1)
                .scaleEffect(isAnimatingTo ? 1.1 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(dragGesture(from: position))
        .accessibilityIdentifier("hole-\(position.row)-\(position.col)")
        .accessibilityLabel(accessibilityLabel(
            hasPeg: hasPeg,
            isSelected: isSelected,
            isTarget: isTarget,
            isHintFrom: isHintFrom,
            isHintTo: isHintTo
        ))
        .accessibilityHint(hasPeg ? "Double-tap to select this peg" : isTarget ? "Double-tap to jump here" : isHintTo ? "Hint landing hole" : "")
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

    private func fillColor(
        hasPeg: Bool,
        isSelected: Bool,
        isTarget: Bool,
        isHintFrom: Bool,
        isHintTo: Bool,
        isAnimatingFrom: Bool
    ) -> Color {
        if isAnimatingFrom { return theme.holeEmpty }
        if isSelected { return theme.pegSelected }
        if isHintFrom && hasPeg { return theme.pegSelected.opacity(0.85) }
        if isTarget || isHintTo { return theme.pegTarget }
        return hasPeg ? theme.peg : theme.holeEmpty
    }

    private func accessibilityLabel(
        hasPeg: Bool,
        isSelected: Bool,
        isTarget: Bool,
        isHintFrom: Bool,
        isHintTo: Bool
    ) -> String {
        if isHintFrom { return "Hint: jump this peg" }
        if isHintTo { return "Hint landing hole" }
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
