import SwiftUI

@main
struct PegGameIdleApp: App {
    @State private var gameViewModel: GameViewModel
    private let settingsStore: SettingsStore

    init() {
        let deps = AppDependencies.live()
        settingsStore = deps.settingsStore
        _gameViewModel = State(initialValue: GameViewModel(
            repository: deps.gameStateRepository,
            settingsStore: deps.settingsStore
        ))
    }

    var body: some Scene {
        WindowGroup {
            LaunchSplashOverlay {
                RootView(settingsStore: settingsStore)
                    .environment(gameViewModel)
            }
        }
    }
}
