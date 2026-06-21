import SwiftUI

/// Color theme picker with swatch previews.
struct ThemePickerSection: View {
    @Binding var selection: AppColorTheme

    var body: some View {
        Section {
            ForEach(AppColorTheme.allCases) { theme in
                Button {
                    selection = theme
                } label: {
                    ThemeOptionRow(theme: theme, isSelected: selection == theme)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(A11yID.themeOptionPrefix + theme.rawValue)
            }
        } header: {
            Text("Color Theme")
        } footer: {
            Text("Changes the app and board colors. The peg puzzle rules stay the same.")
        }
    }
}

private struct ThemeOptionRow: View {
    let theme: AppColorTheme
    let isSelected: Bool

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            ThemeSwatchStrip(palette: theme.palette)
            VStack(alignment: .leading, spacing: 2) {
                Text(theme.displayName)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(theme.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(theme.palette.accent)
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(theme.displayName), \(theme.subtitle)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// Accent · peg · board preview chips.
struct ThemeSwatchStrip: View {
    let palette: ThemePalette

    var body: some View {
        HStack(spacing: 4) {
            swatch(palette.accent)
            swatch(palette.peg)
            swatch(palette.boardPrimary)
        }
        .accessibilityHidden(true)
    }

    private func swatch(_ color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: 18, height: 18)
            .overlay(Circle().strokeBorder(Color.primary.opacity(0.12), lineWidth: 1))
    }
}
