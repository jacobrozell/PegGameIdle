import AudioToolbox
import AVFoundation

/// Short sound effects gated by user settings. Uses system sounds when no custom assets are bundled.
enum SoundEffects {
    private static var configured = false

    private static func configureSession() {
        guard !configured else { return }
        configured = true
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    static func jump(settings: SettingsStore) {
        play(1104, settings: settings)
    }

    static func complete(settings: SettingsStore) {
        play(1025, settings: settings)
    }

    static func purchase(settings: SettingsStore) {
        play(1057, settings: settings)
    }

    static func prestige(settings: SettingsStore) {
        play(1113, settings: settings)
    }

    static func achievement(settings: SettingsStore) {
        play(1111, settings: settings)
    }

    private static func play(_ id: SystemSoundID, settings: SettingsStore) {
        guard settings.soundEnabled else { return }
        configureSession()
        AudioServicesPlaySystemSound(id)
    }
}
