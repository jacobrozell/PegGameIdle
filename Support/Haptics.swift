import UIKit

/// Haptic feedback gated by user settings.
enum Haptics {
    static func light(settings: SettingsStore) {
        guard settings.hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func medium(settings: SettingsStore) {
        guard settings.hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func heavy(settings: SettingsStore) {
        guard settings.hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    static func error(settings: SettingsStore) {
        guard settings.hapticsEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    static func success(settings: SettingsStore) {
        guard settings.hapticsEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
