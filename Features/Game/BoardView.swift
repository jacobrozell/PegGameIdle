import SwiftUI
import PegGameDomain

/// Renders the triangular peg board and routes taps to the view model.
struct BoardView: View {
    @Bindable var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: Theme.Metrics.pegSpacing) {
            ForEach(0..<viewModel.board.layout.size, id: \.self) { row in
                HStack(spacing: Theme.Metrics.pegSpacing) {
                    ForEach(0...row, id: \.self) { col in
                        holeView(Position(row: row, col: col))
                    }
                }
            }
        }
        .padding()
        .background(Theme.Colors.boardWood, in: RoundedRectangle(cornerRadius: Theme.Metrics.cornerRadius))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Peg board, \(viewModel.pegsRemaining) pegs remaining")
    }

    @ViewBuilder
    private func holeView(_ position: Position) -> some View {
        let hasPeg = viewModel.board.hasPeg(at: position)
        let isSelected = viewModel.isSelected(position)
        let isTarget = viewModel.isTarget(position)

        Button {
            viewModel.tap(position)
        } label: {
            Circle()
                .fill(fillColor(hasPeg: hasPeg, isSelected: isSelected, isTarget: isTarget))
                .overlay {
                    if isTarget {
                        // Non-color cue for the landing hole (a11y: not color-only).
                        Image(systemName: "arrow.down.to.line")
                            .imageScale(.small)
                            .foregroundStyle(.white)
                    } else if isSelected {
                        Circle().strokeBorder(.white, lineWidth: 3)
                    }
                }
                .frame(width: Theme.Metrics.pegDiameter, height: Theme.Metrics.pegDiameter)
        }
        .buttonStyle(.plain)
        // Drag-to-jump, layered so quick taps still hit the button and
        // VoiceOver/Switch Control keep the button's accessibility action. The
        // handlers no-op when `position` holds no peg.
        .simultaneousGesture(dragGesture(from: position))
        .accessibilityIdentifier("hole-\(position.row)-\(position.col)")
        .accessibilityLabel(accessibilityLabel(hasPeg: hasPeg, isSelected: isSelected, isTarget: isTarget))
        .accessibilityHint(hasPeg ? "Double-tap to select this peg" : isTarget ? "Double-tap to jump here" : "")
    }

    private func dragGesture(from position: Position) -> some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { _ in
                if !viewModel.isSelected(position) { viewModel.beginDrag(from: position) }
            }
            .onEnded { value in
                viewModel.endDrag(from: position, translation: value.translation)
            }
    }

    private func fillColor(hasPeg: Bool, isSelected: Bool, isTarget: Bool) -> Color {
        if isSelected { return Theme.Colors.pegSelected }
        if isTarget { return Theme.Colors.pegTarget }
        return hasPeg ? Theme.Colors.peg : Theme.Colors.holeEmpty
    }

    private func accessibilityLabel(hasPeg: Bool, isSelected: Bool, isTarget: Bool) -> String {
        if isSelected { return "Selected peg" }
        if isTarget { return "Empty landing hole" }
        return hasPeg ? "Peg" : "Empty hole"
    }
}
