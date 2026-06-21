import SwiftUI

struct LaunchSplashOverlay<Content: View>: View {
    @ViewBuilder var content: () -> Content

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isActive = true
    @State private var logoOpacity = 1.0
    @State private var scrimOpacity = 1.0

    var body: some View {
        ZStack {
            content()
            if isActive {
                splash.accessibilityHidden(true)
            }
        }
        .onAppear(perform: runTransition)
    }

    private var splash: some View {
        ZStack {
            Theme.Colors.background.opacity(scrimOpacity)
            VStack(spacing: 16) {
                Image(systemName: "circle.grid.3x3.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(Theme.Colors.peg)
                Text("Peg Game Idle")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Theme.Colors.accent)
            }
            .opacity(logoOpacity)
        }
        .ignoresSafeArea()
        .allowsHitTesting(scrimOpacity > 0.05)
    }

    private func runTransition() {
        if ProcessInfo.processInfo.arguments.contains("-reset_state") || reduceMotion {
            isActive = false
            return
        }

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(250))
            withAnimation(.easeInOut(duration: 0.4)) { logoOpacity = 0 }
            withAnimation(.easeInOut(duration: 0.85)) { scrimOpacity = 0 }
            try? await Task.sleep(for: .milliseconds(900))
            isActive = false
        }
    }
}
