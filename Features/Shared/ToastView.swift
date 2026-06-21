import SwiftUI

struct ToastView: View {
    @Environment(GameViewModel.self) private var game
    @Environment(\.themePalette) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let item: ToastItem

    var body: some View {
        Text(item.message)
            .font(.callout.weight(.bold))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .frame(maxWidth: dynamicTypeSize.usesLargeTypeLayout ? .infinity : nil)
            .padding(.horizontal, dynamicTypeSize.usesLargeTypeLayout ? 16 : 0)
            .background(toastBackground)
            .overlay(toastBorder)
            .shadow(radius: 8, y: 3)
            .accessibilityAddTraits(.isStaticText)
            .accessibilityLabel(item.message)
            .onAppear {
                UIAccessibility.post(notification: .announcement, argument: item.message)
            }
            .task(id: item.id) {
                try? await Task.sleep(for: .seconds(2.5))
                if game.toast?.id == item.id {
                    game.dismissCurrentToast()
                }
            }
    }

    @ViewBuilder
    private var toastBackground: some View {
        if dynamicTypeSize.usesLargeTypeLayout {
            RoundedRectangle(cornerRadius: 16, style: .continuous).fill(theme.surfaceElevated)
        } else {
            Capsule().fill(theme.surfaceElevated)
        }
    }

    @ViewBuilder
    private var toastBorder: some View {
        let stroke = item.isAchievement ? theme.prestige : theme.accent
        if dynamicTypeSize.usesLargeTypeLayout {
            RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(stroke, lineWidth: 1.5)
        } else {
            Capsule().stroke(stroke, lineWidth: 1.5)
        }
    }
}

import UIKit
