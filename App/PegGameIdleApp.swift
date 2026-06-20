import SwiftUI

@main
struct PegGameIdleApp: App {
    private let dependencies = AppDependencies.live()

    var body: some Scene {
        WindowGroup {
            GameView(repository: dependencies.gameStateRepository)
        }
    }
}
