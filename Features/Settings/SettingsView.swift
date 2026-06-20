import SwiftUI
import PegGameDomain

/// App settings: feedback preferences, legal/support links, and the destructive
/// "reset all progress" action.
struct SettingsView: View {
    @Bindable var viewModel: SettingsViewModel
    /// Used only for the destructive reset action.
    let gameViewModel: GameViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var confirmingReset = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Feedback") {
                    Toggle("Haptics", isOn: $viewModel.hapticsEnabled)
                        .accessibilityIdentifier("settings-haptics-toggle")
                    Toggle("Sound", isOn: $viewModel.soundEnabled)
                        .accessibilityIdentifier("settings-sound-toggle")
                }

                Section("About") {
                    Link("Privacy Policy", destination: AppLinks.privacy)
                        .accessibilityIdentifier("settings-privacy-link")
                    Link("Support", destination: AppLinks.support)
                        .accessibilityIdentifier("settings-support-link")
                    Link("Accessibility", destination: AppLinks.accessibility)
                        .accessibilityIdentifier("settings-accessibility-link")
                    if let tipJar = AppLinks.tipJar {
                        Link("Leave a Tip", destination: tipJar)
                            .accessibilityIdentifier("settings-tip-link")
                    }
                }

                Section {
                    Button("Reset All Progress", role: .destructive) {
                        confirmingReset = true
                    }
                    .accessibilityIdentifier("settings-reset-button")
                } footer: {
                    Text("Permanently deletes your Peg Points, upgrades, prestige, and streaks on this device.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("settings-done-button")
                }
            }
            .confirmationDialog("Reset everything?", isPresented: $confirmingReset, titleVisibility: .visible) {
                Button("Delete All Progress", role: .destructive) {
                    gameViewModel.resetAllProgress()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This can't be undone.")
            }
        }
    }
}
