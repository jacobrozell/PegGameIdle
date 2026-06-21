import SwiftUI
import Combine
import PegGameDomain

/// Tab shell, foreground timer, toasts, and sheet routing.
struct RootView: View {
    @Environment(GameViewModel.self) private var game
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showSettings = false
    @State private var showOnboarding = false
    @State private var settingsViewModel: SettingsViewModel

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var lastTick = Date()

    init(settingsStore: SettingsStore) {
        _settingsViewModel = State(initialValue: SettingsViewModel(store: settingsStore))
    }

    var body: some View {
        @Bindable var game = game

        TabView(selection: $game.selectedTab) {
            PlayView(showSettings: $showSettings)
                .tabItem { Label("Play", systemImage: "circle.grid.3x3.fill") }
                .tag(AppTab.play)
                .accessibilityIdentifier(A11yID.tabPlay)

            UpgradesView()
                .tabItem { Label("Upgrades", systemImage: "sparkles") }
                .tag(AppTab.upgrades)
                .modifier(OptionalTabBadge(count: game.affordableUpgradeCount))
                .accessibilityLabel(upgradesTabLabel)
                .accessibilityIdentifier(A11yID.tabUpgrades)

            DailyView()
                .tabItem { Label("Daily", systemImage: "calendar") }
                .tag(AppTab.daily)
                .accessibilityIdentifier(A11yID.tabDaily)

            AwardsView()
                .tabItem { Label("Awards", systemImage: "trophy.fill") }
                .tag(AppTab.awards)
                .accessibilityIdentifier(A11yID.tabAwards)
        }
        .tint(Theme.Colors.accent)
        .overlay(alignment: .top) {
            if let toast = game.toast {
                ToastView(item: toast)
                    .padding(.top, 4)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.motionSafe(.spring(duration: 0.3), reduceMotion: reduceMotion), value: game.toast?.id)
        .overlay {
            if game.showPrestigeCelebration {
                PrestigeCelebrationView()
                    .transition(.opacity)
            }
        }
        .animation(.motionSafe(.easeOut(duration: 0.35), reduceMotion: reduceMotion), value: game.showPrestigeCelebration)
        .onReceive(ticker) { now in
            let dt = now.timeIntervalSince(lastTick)
            lastTick = now
            game.tickAutoJumper(seconds: min(dt, 1))
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(viewModel: settingsViewModel, gameViewModel: game)
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView()
                .presentationDetents(
                    dynamicTypeSize.usesLargeTypeLayout ? [.large] : [.medium, .large]
                )
        }
        .sheet(item: $game.offlineReport) { report in
            WelcomeBackSheet(report: report)
                .presentationDetents(
                    dynamicTypeSize.usesLargeTypeLayout ? [.large] : [.medium, .large]
                )
        }
        .sheet(item: $game.boardResult) { result in
            BoardResultSheet(result: result)
                .presentationDetents([.medium, .large])
        }
        .sheet(item: $game.dailyResult) { result in
            DailyResultSheet(result: result)
                .presentationDetents([.medium])
        }
        .sheet(item: $game.prestigePresentation) { presentation in
            PrestigeSheet(presentation: presentation)
                .presentationDetents([.medium, .large])
        }
        .onAppear {
            if game.shouldShowOnboarding || ProcessInfo.processInfo.arguments.contains("-ui_test_show_onboarding") {
                showOnboarding = true
            }
        }
        .onChange(of: game.showOnboardingRequest) { _, requested in
            if requested {
                showOnboarding = true
                game.showOnboardingRequest = false
            }
        }
    }

    private var upgradesTabLabel: String {
        let count = game.affordableUpgradeCount
        guard count > 0 else { return "Upgrades" }
        return "Upgrades, \(count) affordable"
    }
}
