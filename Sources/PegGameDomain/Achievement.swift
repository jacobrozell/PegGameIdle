import Foundation

/// Stable milestone identifiers persisted in save data.
public enum AchievementID: String, Codable, CaseIterable, Sendable, Hashable {
    case firstJump = "first_jump"
    case firstBoard = "first_board"
    case genius
    case streak3 = "streak_3"
    case streak7 = "streak_7"
    case boards10 = "boards_10"
    case boards100 = "boards_100"
    case upgradeMax = "upgrade_max"
    case prestige1 = "prestige_1"
    case prestige5 = "prestige_5"
    case pegPoints1k = "peg_points_1k"
    case pegPoints1m = "peg_points_1m"
    case centerPeg = "center_peg"
}

/// Catalog entry for a milestone. Icon is an SF Symbol name for the Features layer.
public struct AchievementDefinition: Sendable, Equatable, Identifiable {
    public var id: AchievementID { achievementID }
    public let achievementID: AchievementID
    public let title: String
    public let description: String
    public let icon: String

    public init(achievementID: AchievementID, title: String, description: String, icon: String) {
        self.achievementID = achievementID
        self.title = title
        self.description = description
        self.icon = icon
    }
}

public enum AchievementCatalog {
    public static let all: [AchievementDefinition] = [
        AchievementDefinition(achievementID: .firstJump, title: "First Jump", description: "Make your first manual jump.", icon: "arrow.up.forward"),
        AchievementDefinition(achievementID: .firstBoard, title: "Board Cleared", description: "Finish your first board.", icon: "checkmark.circle"),
        AchievementDefinition(achievementID: .genius, title: "Expert", description: "Finish a board with one peg left.", icon: "brain.head.profile"),
        AchievementDefinition(achievementID: .streak3, title: "Three-Day Streak", description: "Complete the Daily Puzzle three days in a row.", icon: "flame"),
        AchievementDefinition(achievementID: .streak7, title: "Week Warrior", description: "Complete the Daily Puzzle seven days in a row.", icon: "flame.fill"),
        AchievementDefinition(achievementID: .boards10, title: "Regular", description: "Complete 10 boards.", icon: "square.grid.3x3"),
        AchievementDefinition(achievementID: .boards100, title: "Centurion", description: "Complete 100 boards.", icon: "star.circle"),
        AchievementDefinition(achievementID: .upgradeMax, title: "Maxed Out", description: "Max out any upgrade.", icon: "arrow.up.circle.fill"),
        AchievementDefinition(achievementID: .prestige1, title: "Fresh Start", description: "Prestige for the first time.", icon: "sparkles"),
        AchievementDefinition(achievementID: .prestige5, title: "Veteran", description: "Prestige five times.", icon: "star.fill"),
        AchievementDefinition(achievementID: .pegPoints1k, title: "Thousand Points", description: "Earn 1,000 Peg Points lifetime.", icon: "dollarsign.circle"),
        AchievementDefinition(achievementID: .pegPoints1m, title: "Millionaire", description: "Earn 1,000,000 Peg Points lifetime.", icon: "banknote"),
        AchievementDefinition(achievementID: .centerPeg, title: "Bullseye", description: "Finish with the center peg.", icon: "scope"),
    ]

    public static func definition(for id: AchievementID) -> AchievementDefinition? {
        all.first { $0.achievementID == id }
    }
}
