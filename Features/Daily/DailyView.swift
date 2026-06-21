import SwiftUI
import PegGameDomain

struct DailyView: View {
    @Environment(GameViewModel.self) private var game
    @Environment(\.themePalette) private var theme

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground(showParticles: game.ambientParticlesEnabled)
                VStack(spacing: Theme.Spacing.sm) {
                    CurrencyHeader()
                    ScrollView {
                        VStack(spacing: Theme.Spacing.lg) {
                            streakHeader
                            DailyCalendarView()
                            todayCard
                        }
                        .padding(.horizontal)
                        .padding(.bottom, Theme.Spacing.md)
                    }
                }
            }
            .navigationTitle("Daily")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var streakHeader: some View {
        HStack {
            Label("\(game.dailyStreak)-day streak", systemImage: "flame.fill")
                .font(.headline)
                .foregroundStyle(theme.warning)
            Spacer()
            if game.pendingPrestige > 0 {
                Text("+\(game.pendingPrestige) prestige ready")
                    .font(.caption)
                    .foregroundStyle(theme.prestige)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var todayCard: some View {
        Card(content: {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                Text("Today's Puzzle")
                    .font(Theme.Typography.sectionTitle())
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if game.dailyClaimedToday {
                    solvedTodayContent
                } else {
                    Button {
                        game.startDailyPuzzle()
                    } label: {
                        Label("Play Daily", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.brandedPrimary)
                    .accessibilityIdentifier(A11yID.dailyPlay)
                }
            }
        })
    }

    private var solvedTodayContent: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Label("Solved today", systemImage: "checkmark.seal.fill")
                .foregroundStyle(theme.success)

            if let rank = game.todayDailyRank {
                HStack {
                    Text(rank.displayName)
                        .font(.headline)
                        .foregroundStyle(theme.accent)
                    Spacer()
                    if let pegs = game.todayDailyPegsLeft {
                        Text("\(pegs) peg\(pegs == 1 ? "" : "s") left")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Button {
                game.selectedTab = .play
            } label: {
                Label("View board", systemImage: "circle.grid.3x3")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.brandedSecondary)
            .accessibilityIdentifier(A11yID.dailyViewBoard)

            Button {
                game.startDailyPuzzle()
            } label: {
                Label("Practice again", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(theme.accent)
            .accessibilityIdentifier(A11yID.dailyPractice)
        }
    }

    private var subtitle: String {
        if game.dailyClaimedToday {
            return "Prestige claimed — practice won't change today's reward."
        }
        return "Same board for everyone today — prestige progress scales with rank."
    }
}

struct DailyCalendarView: View {
    @Environment(GameViewModel.self) private var game
    @Environment(\.themePalette) private var theme

    private var today: Date { Date() }
    private var calendar: Calendar { Calendar.current }

    var body: some View {
        let days = daysInMonth()
        Card(content: {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text(monthTitle)
                    .font(.subheadline.weight(.semibold))
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 6) {
                    ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { d in
                        Text(d).font(.caption2.weight(.bold)).foregroundStyle(.secondary)
                    }
                    ForEach(days, id: \.self) { day in
                        dayCell(day)
                    }
                }
            }
        })
    }

    private var monthTitle: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: today)
    }

    private func daysInMonth() -> [Date?] {
        guard
            let range = calendar.range(of: .day, in: .month, for: today),
            let first = calendar.date(from: calendar.dateComponents([.year, .month], from: today))
        else { return [] }

        let weekday = calendar.component(.weekday, from: first)
        let leading = (weekday - calendar.firstWeekday + 7) % 7
        var days: [Date?] = Array(repeating: nil, count: leading)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: first) {
                days.append(date)
            }
        }
        return days
    }

    @ViewBuilder
    private func dayCell(_ date: Date?) -> some View {
        if let date {
            let dayNum = calendar.component(.day, from: date)
            let isToday = calendar.isDateInToday(date)
            let solved = isSolved(date)

            ZStack {
                Circle()
                    .fill(isToday ? theme.accent.opacity(0.25) : Color.clear)
                    .frame(width: 28, height: 28)
                if solved {
                    Image(systemName: "checkmark")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(theme.success)
                } else {
                    Text("\(dayNum)")
                        .font(.caption2)
                        .foregroundStyle(isToday ? theme.accent : .primary)
                }
            }
            .frame(height: 32)
            .accessibilityLabel("\(dayNum)\(isToday ? ", today" : "")\(solved ? ", solved" : "")")
        } else {
            Color.clear.frame(height: 32)
        }
    }

    private func isSolved(_ date: Date) -> Bool {
        let dayNum = DailyPuzzle.dayNumber(for: date)
        let todayNum = DailyPuzzle.dayNumber(for: today)
        if dayNum > todayNum { return false }
        guard let lastDay = game.state.lastDailyDay else { return false }
        if dayNum > lastDay { return false }
        if dayNum == lastDay { return true }
        return lastDay - dayNum < game.dailyStreak
    }
}
