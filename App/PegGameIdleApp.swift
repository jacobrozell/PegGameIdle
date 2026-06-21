import SwiftUI

@main
struct PegGameIdleApp: App {
    @State private var gameViewModel: GameViewModel
    @State private var settingsViewModel: SettingsViewModel

    init() {
        let deps = AppDependencies.live()
        _settingsViewModel = State(initialValue: SettingsViewModel(store: deps.settingsStore))
        _gameViewModel = State(initialValue: GameViewModel(
            repository: deps.gameStateRepository,
            settingsStore: deps.settingsStore
        ))
    }

    var body: some Scene {
        @Bindable var settings = settingsViewModel
        WindowGroup {
            LaunchSplashOverlay {
                RootView(settingsViewModel: settingsViewModel)
                    .environment(gameViewModel)
            }
            .environment(\.themePalette, settings.colorTheme.palette)
        }
    }
}
