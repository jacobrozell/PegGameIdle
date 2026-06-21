import Foundation
import CoreGraphics
import Observation
import PegGameDomain

/// Drives the app: peg board, idle earnings, meta-progression, and presentation state.
@MainActor
@Observable
public final class GameViewModel {
    public enum Mode: Equatable { case normal, daily }

    public private(set) var board: Board
    public private(set) var mode: Mode = .normal
    public private(set) var state: GameState

    public private(set) var selection: Position?
    public private(set) var targets: Set<Position> = []

    // Sheet presentation models
    public var offlineReport: EconomyEngine.OfflineReport?
    public var boardResult: EconomyEngine.BoardResult?
    public var dailyResult: EconomyEngine.DailyResult?
    public var prestigePresentation: PrestigePresentation?

    public var toast: ToastItem?
    var selectedTab: AppTab = .play
    var showPrestigeCelebration = false

    /// Board motion state for animations.
    public private(set) var animatingJump: (from: Position, to: Position)?
    public private(set) var shakePosition: Position?
    public private(set) var boardDealGeneration: Int = 0
    public private(set) var hintMove: Move?

    private struct UndoEntry {
        let move: Move
        let reward: Double
        let earningsBefore: Double
    }

    private var undoStack: [UndoEntry] = []
    private static let maxUndoDepth = 50
    private var currentBoardEarnings: Double = 0
    private var autoBoard: Board
    private let repository: GameStateRepository
    let settingsStore: SettingsStore
    private let autoPlayer = AutoPlayer(strategy: .greedy)
    private var rng = SystemRandomNumberGenerator()
    private var prestigeNudgeShown = false
    private var upgradeNudgeShown = false
    private var toastQueue: [ToastItem] = []

    public init(repository: GameStateRepository, settingsStore: SettingsStore, now: Date = .init()) {
        self.repository = repository
        self.settingsStore = settingsStore
        let loaded = repository.load()
        let reconciled = EconomyEngine.reconcileOffline(now: now, state: loaded)
        self.state = reconciled.state
        let layout = reconciled.state.boardLayout
        self.board = Board(layout: layout, empty: Position(row: 0, col: 0))
        self.autoBoard = Board(layout: layout, empty: Position(row: 0, col: 0))
        if reconciled.report.jumps > 0 {
            self.offlineReport = reconciled.report
        }
        repository.save(reconciled.state)
        prepareUITestHooks()
    }

    // MARK: Presentation

    public var pegPoints: Double { state.pegPoints }
    public var pegPointsText: String { NumberFormatting.compact(state.pegPoints) }
    public var pegsRemaining: Int { board.pegCount }
    public var autoJumpsPerSecond: Double { state.autoJumpsPerSecond }
    public var isBoardFinished: Bool { board.isGameOver }
    public var didWin: Bool { board.isSolved }
    public var streakCount: Int { state.streakCount }
    public var isDailyMode: Bool { mode == .daily }
    public var stats: StatsSnapshot { StatsSnapshot(state: state) }
    public var ambientParticlesEnabled: Bool { settingsStore.ambientParticlesEnabled }
    public var boardLayoutName: String { board.layout.displayName }
    public var canUndo: Bool { !undoStack.isEmpty && !board.isGameOver }
    public var canHint: Bool { animatingJump == nil && !board.isGameOver && !board.legalMoves().isEmpty }
    public var hasActiveHint: Bool { hintMove != nil }
    public var isInteractionLocked: Bool { animatingJump != nil || board.isGameOver }

    public var affordableUpgradeCount: Int {
        UpgradeKind.allCases.filter { canAfford($0) && !state.isMaxLevel($0) }.count
    }

    public var prestigeProgressFraction: Double {
        EconomyEngine.prestigeProgressFraction(in: state)
    }

    public var globalMultiplierText: String {
        String(format: "%.2f×", state.prestigeMultiplier * state.achievementMultiplier)
    }

    // MARK: Prestige

    public var prestigeMultiplier: Double { state.prestigeMultiplier }
    public var prestigeMultiplierText: String { String(format: "%.1f×", state.prestigeMultiplier) }
    public var pendingPrestige: Int { Int(EconomyEngine.pendingPrestige(in: state)) }
    public var canPrestige: Bool { EconomyEngine.canPrestige(state) }
    public var projectedMultiplierText: String {
        String(format: "%.1f×", EconomyEngine.projectedMultiplier(after: state))
    }

    public func showPrestigeSheet() {
        prestigePresentation = PrestigePresentation(
            pendingPoints: pendingPrestige,
            currentMultiplier: state.prestigeMultiplier * state.achievementMultiplier,
            projectedMultiplier: EconomyEngine.projectedMultiplier(after: state) * state.achievementMultiplier
        )
    }

    public func prestige() {
        guard canPrestige else { return }
        let before = state.prestigeMultiplier * state.achievementMultiplier
        state = EconomyEngine.prestige(state)
        evaluateAchievements(for: .prestigePerformed(totalPrestiges: state.totalPrestiges))
        dealNormalBoard()
        persist()
        Haptics.heavy(settings: settingsStore)
        SoundEffects.prestige(settings: settingsStore)
        showToast("Prestiged! \(String(format: "%.2f×", before)) → \(globalMultiplierText)")
        prestigePresentation = nil
        triggerPrestigeCelebration()
    }

    private func triggerPrestigeCelebration() {
        showPrestigeCelebration = true
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            if showPrestigeCelebration { showPrestigeCelebration = false }
        }
    }

    // MARK: Daily Puzzle

    public var dailyStreak: Int { state.dailyStreak }
    public var dailyClaimedToday: Bool {
        state.lastDailyDay == DailyPuzzle.dayNumber(for: Date())
    }

    public var todayDailyRank: BoardRank? {
        guard dailyClaimedToday else { return nil }
        return state.lastDailyRank
    }

    public var todayDailyPegsLeft: Int? {
        guard dailyClaimedToday else { return nil }
        return state.lastDailyPegsLeft
    }

    public func startDailyPuzzle(now: Date = .init()) {
        board = DailyPuzzle.board(for: now)
        mode = .daily
        currentBoardEarnings = 0
        boardDealGeneration += 1
        clearSelection()
        clearUndoAndHint()
        selectedTab = .play
    }

    public func dismissDailyResult() { dailyResult = nil }

    // MARK: Onboarding

    public var shouldShowOnboarding: Bool { !state.hasSeenOnboarding }

    public func markOnboardingSeen() {
        state.hasSeenOnboarding = true
        persist()
    }

    public func resetOnboardingForReplay() {
        state.hasSeenOnboarding = false
        persist()
    }

    /// When true, RootView presents onboarding (e.g. from Settings → How to play).
    public var showOnboardingRequest = false

    public func requestOnboardingReplay() {
        resetOnboardingForReplay()
        showOnboardingRequest = true
    }

    // MARK: Undo & hint

    public func undoLastMove() {
        guard canUndo, let entry = undoStack.last else { return }
        guard board.reverse(entry.move) else { return }
        undoStack.removeLast()
        state = EconomyEngine.revertManualJump(reward: entry.reward, in: state)
        currentBoardEarnings = entry.earningsBefore
        animatingJump = nil
        shakePosition = nil
        clearSelection()
        hintMove = nil
        Haptics.light(settings: settingsStore)
        persist()
    }

    public func showHint() {
        guard canHint else { return }
        hintMove = BoardHint.suggestedMove(on: board)
        guard hintMove != nil else { return }
        clearSelection()
        Haptics.light(settings: settingsStore)
    }

    public func clearHint() {
        hintMove = nil
    }

    // MARK: Selection / input

    public func isSelected(_ position: Position) -> Bool { selection == position }
    public func isTarget(_ position: Position) -> Bool { targets.contains(position) }

    public func tap(_ position: Position) {
        guard !isInteractionLocked else { return }
        clearHint()
        if let selected = selection {
            if position == selected {
                clearSelection()
            } else if let move = move(from: selected, to: position) {
                perform(move, manual: true)
            } else {
                Haptics.error(settings: settingsStore)
                triggerShake(at: selected)
                select(position)
            }
        } else {
            if board.hasPeg(at: position) {
                Haptics.light(settings: settingsStore)
            }
            select(position)
        }
    }

    public func beginDrag(from position: Position) {
        guard !isInteractionLocked else { return }
        clearHint()
        select(position)
        if board.hasPeg(at: position) {
            Haptics.light(settings: settingsStore)
        }
    }

    public func endDrag(from position: Position, translation: CGSize) {
        guard !isInteractionLocked else { clearSelection(); return }
        let candidates = board.legalMoves().filter { $0.from == position }
        guard !candidates.isEmpty else { clearSelection(); return }

        let drag = (x: Double(translation.width), y: Double(translation.height))
        let dragLen = (drag.x * drag.x + drag.y * drag.y).squareRoot()
        guard dragLen > 1 else { return }

        func similarity(_ move: Move) -> Double {
            let vx = Double(move.to.col - move.from.col) - Double(move.to.row - move.from.row) / 2
            let vy = Double(move.to.row - move.from.row)
            let len = (vx * vx + vy * vy).squareRoot()
            guard len > 0 else { return -1 }
            return (drag.x * vx + drag.y * vy) / (dragLen * len)
        }

        if let best = candidates.max(by: { similarity($0) < similarity($1) }), similarity(best) > 0.4 {
            perform(best, manual: true)
        }
    }

    private func select(_ position: Position) {
        guard board.hasPeg(at: position) else { clearSelection(); return }
        selection = position
        targets = Set(board.legalMoves().filter { $0.from == position }.map(\.to))
    }

    private func clearSelection() {
        selection = nil
        targets = []
    }

    private func move(from: Position, to: Position) -> Move? {
        board.legalMoves().first { $0.from == from && $0.to == to }
    }

    private func perform(_ move: Move, manual: Bool) {
        guard animatingJump == nil, !board.isGameOver else { return }
        let reward = state.reward(forJumping: 1)
        let earningsBefore = currentBoardEarnings
        animatingJump = (move.from, move.to)
        guard board.apply(move) else {
            animatingJump = nil
            return
        }
        state = EconomyEngine.awardJumps(1, to: state, manual: manual)
        currentBoardEarnings += reward
        if manual {
            if undoStack.count >= Self.maxUndoDepth { undoStack.removeFirst() }
            undoStack.append(UndoEntry(move: move, reward: reward, earningsBefore: earningsBefore))
            hintMove = nil
        }
        clearSelection()
        Haptics.medium(settings: settingsStore)
        SoundEffects.jump(settings: settingsStore)
        if manual {
            evaluateAchievements(for: .manualJump)
            announceCurrencyGain(reward)
        }
        settleIfFinished()
        persist()
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(250))
            animatingJump = nil
        }
    }

    private func triggerShake(at position: Position) {
        shakePosition = position
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(300))
            if shakePosition == position { shakePosition = nil }
        }
    }

    private func settleIfFinished() {
        guard board.isGameOver else { return }
        undoStack.removeAll()
        hintMove = nil
        let finalPeg = board.pegs.first
        switch mode {
        case .normal:
            let outcome = EconomyEngine.completeBoard(
                pegsLeft: board.pegCount,
                finalPeg: finalPeg,
                boardLayout: board.layout,
                boardEarnings: currentBoardEarnings,
                state: state
            )
            state = outcome.state
            boardResult = outcome.result
            evaluateAchievements(for: .boardCompleted(
                pegsLeft: outcome.result.pegsLeft,
                landedCenterPeg: outcome.result.landedCenterPeg
            ))
            Haptics.success(settings: settingsStore)
            SoundEffects.complete(settings: settingsStore)
            nudgeUpgradesIfNeeded()
        case .daily:
            let outcome = EconomyEngine.completeDaily(pegsLeft: board.pegCount, on: Date(), state: state)
            state = outcome.state
            if !outcome.result.alreadyClaimed {
                dailyResult = outcome.result
                evaluateAchievements(for: .dailyCompleted(streak: outcome.result.dailyStreak))
            }
            Haptics.success(settings: settingsStore)
            SoundEffects.complete(settings: settingsStore)
        }
        dealNormalBoard()
    }

    // MARK: Auto-Jumper

    public func tickAutoJumper(seconds: Double) {
        let jumps = Int((state.autoJumpsPerSecond * seconds).rounded(.down))
        guard jumps > 0 else { return }
        var played = 0
        for _ in 0..<jumps {
            if autoBoard.isGameOver {
                autoBoard = Board(layout: state.boardLayout, empty: Position(row: 0, col: 0))
            }
            guard let move = autoPlayer.nextMove(on: autoBoard, using: &rng) else { break }
            autoBoard.apply(move)
            played += 1
        }
        if played > 0 {
            state = EconomyEngine.awardJumps(played, to: state)
            persist()
            nudgePrestigeIfNeeded()
        }
    }

    private func nudgePrestigeIfNeeded() {
        guard canPrestige, !prestigeNudgeShown else { return }
        prestigeNudgeShown = true
        showToast("Prestige available!")
    }

    // MARK: Board management

    public func dealNormalBoard(empty: Position = Position(row: 0, col: 0)) {
        let layout = state.boardLayout
        board = Board(layout: layout, empty: empty)
        mode = .normal
        currentBoardEarnings = 0
        boardDealGeneration += 1
        clearSelection()
        clearUndoAndHint()
        syncAutoBoardLayoutIfNeeded()
    }

    private func syncAutoBoardLayoutIfNeeded() {
        guard autoBoard.layout != state.boardLayout else { return }
        autoBoard = Board(layout: state.boardLayout, empty: Position(row: 0, col: 0))
    }

    private func clearPresentationState() {
        offlineReport = nil
        boardResult = nil
        dailyResult = nil
        prestigePresentation = nil
        toast = nil
        toastQueue.removeAll()
        showPrestigeCelebration = false
        prestigeNudgeShown = false
    }

    private func clearUndoAndHint() {
        undoStack.removeAll()
        hintMove = nil
    }

    public func dismissOfflineReport() { offlineReport = nil }
    public func dismissBoardResult() { boardResult = nil }

    public func resetAllProgress() {
        repository.reset()
        state = repository.load()
        currentBoardEarnings = 0
        clearPresentationState()
        upgradeNudgeShown = false
        selectedTab = .play
        dealNormalBoard()
    }

    // MARK: Upgrades

    public func purchase(_ kind: UpgradeKind, levels: Int = 1) {
        let before = state.level(of: kind)
        state = EconomyEngine.purchaseBulk(kind, levels: levels, in: state)
        guard state.level(of: kind) > before else { return }
        evaluateAchievements(for: .upgradePurchased(kind: kind, newLevel: state.level(of: kind)))
        if kind == .boardSize {
            dealNormalBoard()
            showToast("Board upgraded to \(state.boardLayout.displayName)")
        } else {
            showToast("\(kind.displayName) → Lv \(state.level(of: kind))")
        }
        persist()
        Haptics.medium(settings: settingsStore)
        SoundEffects.purchase(settings: settingsStore)
    }

    public func canAfford(_ kind: UpgradeKind) -> Bool {
        !state.isMaxLevel(kind) && state.pegPoints >= EconomyEngine.cost(of: kind, in: state)
    }

    public func cost(of kind: UpgradeKind) -> Double { EconomyEngine.cost(of: kind, in: state) }
    public func bulkCost(of kind: UpgradeKind, levels: Int) -> Double {
        EconomyEngine.bulkUpgradeCost(kind, levels: levels, in: state)
    }
    public func maxAffordable(for kind: UpgradeKind) -> Int {
        EconomyEngine.maxAffordableLevels(kind, in: state)
    }

    public func level(of kind: UpgradeKind) -> Int { state.level(of: kind) }
    public func isMaxLevel(_ kind: UpgradeKind) -> Bool { state.isMaxLevel(kind) }

    public func effectDescription(for kind: UpgradeKind, at level: Int? = nil) -> String {
        kind.effectDescription(at: level ?? state.level(of: kind))
    }

    public func nextEffectDescription(for kind: UpgradeKind) -> String? {
        guard !state.isMaxLevel(kind) else { return nil }
        return kind.effectDescription(at: state.level(of: kind) + 1)
    }

    // MARK: Achievements

    public func evaluateAchievements(for event: GameEvent) {
        let newIDs = AchievementEngine.newlyUnlocked(state: state, event: event)
        guard !newIDs.isEmpty else { return }
        for id in newIDs {
            state.unlockedAchievements.insert(id)
            if let def = AchievementCatalog.definition(for: id) {
                showToast("Award: \(def.title)", isAchievement: true)
                Haptics.success(settings: settingsStore)
                SoundEffects.achievement(settings: settingsStore)
            }
        }
        persist()
    }

    public func isAchievementUnlocked(_ id: AchievementID) -> Bool {
        state.unlockedAchievements.contains(id)
    }

    // MARK: Export / import

    public func exportSaveJSON() -> String? {
        guard let data = try? JSONEncoder().encode(state) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    public func importSaveJSON(_ json: String) -> Bool {
        guard
            let data = json.data(using: .utf8),
            let imported = try? JSONDecoder().decode(GameState.self, from: data)
        else { return false }
        state = imported
        clearPresentationState()
        upgradeNudgeShown = false
        dealNormalBoard()
        persist()
        return true
    }

    // MARK: UI test hooks

    private func prepareUITestHooks() {
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-ui_test_show_onboarding") {
            state.hasSeenOnboarding = false
        }
        if args.contains("-ui_test_offline_report") {
            offlineReport = EconomyEngine.OfflineReport(
                jumps: 42,
                pegPointsEarned: 420,
                effectiveSeconds: 3600,
                wasCapped: false,
                elapsedSeconds: 3600,
                capHours: 4,
                jumpsPerSecond: 0.5
            )
        }
    }

    // MARK: Toast

    public func dismissCurrentToast() {
        if toastQueue.isEmpty {
            toast = nil
        } else {
            toast = toastQueue.removeFirst()
        }
    }

    // MARK: Private

    private func showToast(_ message: String, isAchievement: Bool = false) {
        let item = ToastItem(message: message, isAchievement: isAchievement)
        if toast == nil {
            toast = item
        } else {
            toastQueue.append(item)
        }
    }

    private func nudgeUpgradesIfNeeded() {
        guard !upgradeNudgeShown else { return }
        guard state.totalBoardsCompleted >= 3 else { return }
        guard UpgradeKind.allCases.allSatisfy({ state.level(of: $0) == 0 }) else { return }
        upgradeNudgeShown = true
        showToast("Try Upgrades to earn faster!")
    }

    private func announceCurrencyGain(_ amount: Double) {
        guard amount > 0 else { return }
        UIAccessibility.post(notification: .announcement, argument: "+\(NumberFormatting.compact(amount)) Peg Points")
    }

    private func persist() {
        var snapshot = state
        snapshot.lastSeen = Date()
        state.lastSeen = snapshot.lastSeen
        repository.save(snapshot)
    }
}

import UIKit
