import Foundation

/// Root tab selection — owned by `GameViewModel` so features can switch tabs.
enum AppTab: Int, Hashable, CaseIterable {
    case play
    case upgrades
    case daily
    case awards
}
