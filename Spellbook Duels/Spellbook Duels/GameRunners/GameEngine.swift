//
//  GameEngine.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 11/26/25.
//
import Combine
import SwiftUI
import FirebaseDatabase

final class GameEngine: ObservableObject {
    @Published var board: BoardModel
    
    @Published var isAskingToTurnPage: Bool = false
    
    @Published var isAskingPlayerToActivate: Bool = false
    @Published var isAskingOpponentToActivate: Bool = false
    
    @Published var isAskingToDiscardForHandLimit: Bool = false
    @Published var pendingHandLimitCards: [String] = []
    @Published var pendingHandLimitOwner: PlayerSide? = nil
    
    @Published var hasCastNewAttackSpellThisTurn: Bool = false
    
    var monitors: Monitors = Monitors()
    
    let handSize = 6
    
    var activePlayer: PlayerSide { get { board.activePlayer } set { board.activePlayer = newValue } }
    var phase: Phase { get { board.phase } set { board.phase = newValue } }
    var isPlayersTurn: Bool { board.activePlayer == .player }

    init() {
        self.board = BoardModel()
        
        AbilityStack = [:]
        AbilitySources = [:]
        
        resetStackAndSources()
    }
    
    init(playerFirst: PlayerSide) {
        self.board = BoardModel()
        
        AbilityStack = [:]
        AbilitySources = [:]
        
        resetStackAndSources()
        
        startNewGame(playerFirst: .player)
    }
    
    // MARK: - New Game
    func startNewGame(initialBoard: BoardModel = BoardModel(), playerFirst: PlayerSide, initialPhase: Phase = .defend) {
        board = initialBoard
        board.activePlayer = playerFirst
        board.phase = initialPhase
        isAskingToTurnPage = false
        monitors = Monitors()
        resetStackAndSources()
        if initialPhase == .defend {
            startDefendPhase()
        }
    }
    
    // MARK: - Play Data Structures
    
    var AbilityStack: [Int: [CardEffect]]
    var AbilitySources: [Int: [CardSlot]]
    var noAbilitiesOnStack: Bool {
        if !AbilityStack[1]!.isEmpty || !AbilityStack[2]!.isEmpty || !AbilityStack[3]!.isEmpty || !AbilityStack[4]!.isEmpty || !AbilityStack[5]!.isEmpty { return false }
        return true
    }
    
    func resetStackAndSources() {
        AbilityStack = [:]
        AbilityStack[1] = []
        AbilityStack[2] = []
        AbilityStack[3] = []
        AbilityStack[4] = []
        AbilityStack[5] = []
        
        AbilitySources = [:]
        AbilitySources[1] = []
        AbilitySources[2] = []
        AbilitySources[3] = []
        AbilitySources[4] = []
        AbilitySources[5] = []
    }

    // MARK: - Game Actions
    
    func dealDamage(sourceOwner: PlayerSide, sourceZone: CardZone, target: PlayerSide, amount: Int) {
        let sourceSlot = board.getSlot(sourceOwner, sourceZone)
        guard !sourceSlot.card.isEmpty else { return }

        var context = DealDamageContext(source: sourceSlot, target: target, amount: amount)

        for entry in monitors.dealDamage.entries where entry.step == .beforeDamage {
            entry.handler(&context, &board)
            if context.cancelled { return }
        }

        switch context.target {
        case .player: loseAether(sourceSlot: context.source, target: context.target, amount: context.amount, aetherTotal: &board.playerAetherTotal)
        case .opponent: loseAether(sourceSlot: context.source, target: context.target, amount: context.amount, aetherTotal: &board.opponentAetherTotal)
        }

        for entry in monitors.dealDamage.entries where entry.step == .afterDamage {
            entry.handler(&context, &board)
            if context.cancelled { break }
        }
    }
    
    func loseAether(sourceSlot: CardSlot, target: PlayerSide, amount: Int, aetherTotal: inout Int) {
        guard !sourceSlot.card.isEmpty else { return }

        var ctx = LoseAetherContext(source: sourceSlot, player: target, amount: amount)

        for entry in monitors.loseAether.entries where entry.step == .beforeLose {
            entry.handler(&ctx, &board)
            if ctx.cancelled { return }
        }

        switch ctx.player {
        case .player:   board.playerAetherTotal   -= ctx.amount
        case .opponent: board.opponentAetherTotal -= ctx.amount
        }

        for entry in monitors.loseAether.entries where entry.step == .afterLose {
            entry.handler(&ctx, &board)
            if ctx.cancelled { break }
        }
    }
    
    func payAether(for card: PresentedCardModel, owner: PlayerSide, baseCost: Int) -> Bool {
        var context = PayAetherContext(player: owner, card: card.cardCode, cost: baseCost)

        for entry in monitors.payAether.entries where entry.step == .beforePay {
            entry.handler(&context, &board)
            if context.cancelled {
                return false
            }
        }

        let currentAether: Int
        switch context.player {
        case .player: currentAether = board.playerAetherTotal
        case .opponent: currentAether = board.opponentAetherTotal
        }

        guard currentAether >= context.cost else {
            return false
        }

        switch context.player {
        case .player:
            board.playerAetherTotal -= context.cost
        case .opponent:
            board.opponentAetherTotal -= context.cost
        }

        for entry in monitors.payAether.entries where entry.step == .afterPay {
            entry.handler(&context, &board)
            if context.cancelled {
                break
            }
        }

        return true
    }

    func gainAether(sourceOwner: PlayerSide, for player: PlayerSide, amount: Int) {
        var context = GainAetherContext(player: player, amount: amount)

        for entry in monitors.gainAether.entries where entry.step == .beforeGain {
            entry.handler(&context, &board)
            if context.cancelled { return }
        }

        switch context.player {
        case .player:   board.playerAetherTotal   += context.amount
        case .opponent: board.opponentAetherTotal += context.amount
        }
        
        for entry in monitors.gainAether.entries where entry.step == .afterGain {
            entry.handler(&context, &board)
            if context.cancelled { return }
        }
    }

    func breakCard(sourceOwner: PlayerSide, zone: CardZone, target: CardSlot) {
        let slot = board.slot(for: sourceOwner, zone: zone)
        guard !slot.card.isEmpty else { return }

        var context = BreakCardContext(source: slot, target: target)

        for entry in monitors.breakCard.entries where entry.step == .beforeBreak {
            entry.handler(&context, &board)
            if context.cancelled { return }
        }
        
        discardFromField(slot: target)
        
        for entry in monitors.breakCard.entries where entry.step == .afterBreak {
            entry.handler(&context, &board)
            if context.cancelled { return }
        }

    }
    
    func discardFromField(slot: CardSlot) {
        guard !slot.card.isEmpty else { return }

        if let card = PresentedCardModel.cardByCode[slot.card],
           let def = CardEffects.registry[card.cardCode] {
            def.onLeaveField?(slot, self)
        }

        var context = DiscardFromFieldContext(card: slot, cardOwner: slot.owner)

        for entry in monitors.discardFromField.entries where entry.step == .beforeDiscardFromField {
            entry.handler(&context, &board)
        }

        monitors.removeAllMonitors(for: slot)

        var empty = slot
        empty.card = ""
        empty.counters = [:]
        board.setSlot(empty)

        for entry in monitors.discardFromField.entries where entry.step == .afterDiscardFromField {
            entry.handler(&context, &board)
        }
    }
    
    func pullToHand(slot: CardSlot) {
        guard !slot.card.isEmpty else { return }

        if let card = PresentedCardModel.cardByCode[slot.card],
           let def = CardEffects.registry[card.cardCode] {
            def.onLeaveField?(slot, self)
        }

        var context = PullToHandContext(card: slot, cardOwner: slot.owner)

        for entry in monitors.pullToHand.entries where entry.step == .beforePullToHand {
            entry.handler(&context, &board)
        }

        monitors.removeAllMonitors(for: slot)
        
        addCardsToHand([slot.card], player: context.cardOwner)

        var empty = slot
        empty.card = ""
        empty.counters = [:]
        board.setSlot(empty)
        
        enforceHandLimit()

        for entry in monitors.pullToHand.entries where entry.step == .afterPullToHand {
            entry.handler(&context, &board)
        }
    }
    
    func playCard(fromHandIndex index: Int, owner: PlayerSide, to zone: CardZone, hand: inout [String], chosenN: Int? = nil) {
        let cardCode = hand[index]
        guard let card = PresentedCardModel.cardByCode[cardCode] else { return }

        var slot = CardSlot(owner: owner, zone: zone, card: cardCode)
        
        if let n = chosenN { slot.counters[Counter.N] = n }
        
        let hasAetherCost: Bool
        switch card.type {
        case .potion:
            hasAetherCost = false
        default:
            hasAetherCost = true
        }
        
        if hasAetherCost {
            let baseCost = chosenN ?? card.costVal

            guard payAether(for: card, owner: owner, baseCost: baseCost) else {
                return
            }
        }
        
        if board.playerPotionBrewed || board.opponentPotionBrewed {
            checkForPotionActivationsPt1()
            
            if board.phase == .action {
                resolveStack()
            }
        }

        switch card.type {
        case .jinx, .counterspell:
            playSnap(card: card, into: slot)
        case .curse, .ward, .charm, .relic, .potion:
            playPermanent(card: card, into: slot)
        }
        
        if card.type == .curse || card.type == .jinx { hasCastNewAttackSpellThisTurn = true }

        hand.remove(at: index)
        board.setHand(hand, owner: owner)
        
        if phase == .attack {
            passAttackPhasePt1()
        }
        if phase == .defend {
            resolveDefendPhase()
        }
    }
    
    private func playPermanent(card: PresentedCardModel, into slot: CardSlot) {
        var context = PlayCardFieldContext(slot: slot, card: card.cardCode)
        
        for entry in monitors.playCard.entries where entry.step == .beforePlay {
            entry.handler(&context, &board)
            if context.cancelled { return }
        }
        
        let existing = board.slot(for: slot.owner, zone: slot.zone)
        if !existing.card.isEmpty {
            discardFromField(slot: existing)
        }

        board.setSlot(slot)
        registerMonitorsForCard(in: slot)

        if let def = CardEffects.registry[card.cardCode] {
            def.onEnterField?(slot, self)
            def.onPlay?(slot, self)
        }
        
        for entry in monitors.playCard.entries where entry.step == .afterPlay {
            entry.handler(&context, &board)
        }
        
        switch (card.type, slot.owner) {
        case (.charm, .player): board.playerCharmTimeCounters = 0; break
        case (.curse, .player): board.playerCurseTimeCounters = 0; break
        case (.ward, .player): board.playerWardTimeCounters = 0; break
            
        case (.charm, .opponent): board.opponentCharmTimeCounters = 0; break
        case (.curse, .opponent): board.opponentCurseTimeCounters = 0; break
        case (.ward, .opponent): board.opponentWardTimeCounters = 0; break
            
        default: break
        }
    }
    
    func playSnap(card: PresentedCardModel, into slot: CardSlot) {
        board.setSlot(slot)
        registerMonitorsForCard(in: slot)

        if let def = CardEffects.registry[card.cardCode] {
            def.onPlay?(slot, self)
        }
    }

    private func cleanupSnapSpells() {
        let playerSnap = board.playerSnap
        if !playerSnap.card.isEmpty {
            discardFromField(slot: playerSnap)
        }

        let opponentSnap = board.opponentSnap
        if !opponentSnap.card.isEmpty {
            discardFromField(slot: opponentSnap)
        }
    }
    
    func activatePotion(owner: PlayerSide) { // No timing check; UI will not allow activation unless the rules allow it
        let slot: CardSlot = (owner == .player) ? board.playerPotion : board.opponentPotion
        guard !slot.card.isEmpty,
            let card = PresentedCardModel.cardByCode[slot.card],
            let def = CardEffects.registry[card.cardCode] else { return }

        AbilityStack[(PresentedCardModel.cardByCode[slot.card]?.speed)!]!.append(def.onActivate!)
        AbilitySources[(PresentedCardModel.cardByCode[slot.card]?.speed)!]!.append(slot)
        
        discardFromField(slot: slot)
    }
    
    func activateRelic(owner: PlayerSide) { // No timing check; UI will not allow activation unless the rules allow it
        let slot: CardSlot = (owner == .player) ? board.playerRelic : board.opponentRelic
        guard !slot.card.isEmpty,
            let card = PresentedCardModel.cardByCode[slot.card],
            let def = CardEffects.registry[card.cardCode] else { return }

        AbilityStack[1]!.append(def.onActivate!)
        AbilitySources[1]!.append(slot)

        if slot.card != "WSE" {
            discardFromField(slot: slot)
        } else {
            resolveStack()
        }
    }
    
    func resolveStack() {
        for speed in (1...5).reversed() {
            guard let effects = AbilityStack[speed] else {
                print("[ERROR] AbilityStack[\(speed)] is nil during resolveStack()")
                    continue
            }
            guard let sources = AbilitySources[speed] else {
                print("[ERROR] AbilitySources[\(speed)] is nil during resolveStack()")
                continue
            }

            guard !effects.isEmpty else { continue }

            guard effects.count == sources.count else {
                print("""
                        [ERROR] Mismatched ability arrays at speed \(speed):
                            effects.count = \(effects.count)
                            sources.count = \(sources.count)
                        """)
                continue
            }

            for i in 0..<effects.count {
                let effect = effects[i]
                let source = sources[i]
                effect(source, self)
            }

            AbilityStack[speed] = []
            AbilitySources[speed] = []
        }
    }
    
    func incrementReplenishCounters() {
        switch board.activePlayer {
        case .player:
            if board.playerCharmTimeCounters != nil { board.playerCharmTimeCounters! += 1 }
            if board.playerCurseTimeCounters != nil { board.playerCurseTimeCounters! += 1 }
            if board.playerWardTimeCounters != nil { board.playerWardTimeCounters! += 1 }
            break
        case .opponent:
            if board.opponentCharmTimeCounters != nil { board.opponentCharmTimeCounters! += 1 }
            if board.opponentCurseTimeCounters != nil { board.opponentCurseTimeCounters! += 1 }
            if board.opponentWardTimeCounters != nil { board.opponentWardTimeCounters! += 1 }
            break
        }
        if board.playerPotionBrewCounters != nil && board.playerPotionBrewed { board.playerPotionBrewCounters! += 1 }
        if board.opponentPotionBrewCounters != nil && board.opponentPotionBrewed { board.opponentPotionBrewCounters! += 1 }
    }
    
    func drawNCards(_ N: Int, player: PlayerSide) {
        if player == .player {
            for _ in 1...N {
                let card = board.playerDeck.removeFirst()
                board.playerHand.append(card)
            }
        } else {
            for _ in 1...N {
                let card = board.opponentDeck.removeFirst()
                board.opponentHand.append(card)
            }
        }
        enforceHandLimit(player)
    }
    
    func addCardsToHand(_ cards: [String], player: PlayerSide) {
        if player == .player {
            board.playerHand.append(contentsOf: cards)
        } else {
            board.opponentHand.append(contentsOf: cards)
        }
        enforceHandLimit(player)
    }
    
    func cardsToDiscard(_ cards: [String], from original: [String], source: NonBoardZone, player: PlayerSide) {
        var toRemoveFrom: [String] = original
        for index in 0..<cards.count {
            if let index = toRemoveFrom.firstIndex(of: cards[index]) {
                let removed = toRemoveFrom.remove(at: index)
                if player == .player {
                    board.playerDiscard.append(removed)
                } else {
                    board.opponentDiscard.append(removed)
                }
            }
        }
        if source == .hand {
            board.setHand(toRemoveFrom, owner: player)
        } else if source == .deck {
            if player == .player {
                board.playerDeck = toRemoveFrom
            } else {
                board.opponentDeck = toRemoveFrom
            }
        }
    }
    
    func enforceHandLimit(_ player: PlayerSide? = nil) {
        let handOwner: PlayerSide = player ?? activePlayer
        let hand = board.getHand(owner: handOwner)
            
        guard hand.count > handSize else { return }
            
        pendingHandLimitCards = hand
        pendingHandLimitOwner = handOwner
        isAskingToDiscardForHandLimit = true
    }
    
    // MARK: - Phase Handling
    
    func startDefendPhase() {
        hasCastNewAttackSpellThisTurn = false
        if !board.previousPlayerIsAttacking {
            resolveDefendPhase()
        }
    }
    
    func resolveDefendPhase() {
        resolveStack()
        cleanupSnapSpells()
        endDefendPhasePt1()
    }
    
    func endDefendPhasePt1() {
        if board.playerPotionBrewed || board.opponentPotionBrewed {
            checkForPotionActivationsPt1()
        }
    }
    
    func endDefendPhasePt2() {
        board.previousPlayerIsAttacking = false
        board.phase = .replenish
        resolveReplenishPhasePt1()
    }
    
    func resolveReplenishPhasePt1() {
        gainAether(sourceOwner: board.activePlayer, for: board.activePlayer, amount: 1)
        incrementReplenishCounters()
        
        if board.playerPotionBrewed || board.opponentPotionBrewed {
            checkForPotionActivationsPt1()
        }
    }
    
    func resolveReplenishPhasePt2() {
        phase = .action
    }
    
    func passFromActionPhasePt1() {
        if board.playerPotionBrewed || board.opponentPotionBrewed {
            checkForPotionActivationsPt1()
        }
    }
    
    func passFromActionPhasePt2() {
        board.previousPlayerIsAttacking = false
        phase = .attack
    }
    
    func passAttackPhasePt1() {
        if board.getSlot(activePlayer, .curse).card != "" || board.getSlot(activePlayer, .snap).card != "" {
            board.previousPlayerIsAttacking = true
        }
        
        if board.playerPotionBrewed || board.opponentPotionBrewed {
            checkForPotionActivationsPt1()
        }
        
    }
    
    func passAttackPhasePt2() {
        if activePlayer == .player {
            activePlayer = .opponent
        } else {
            activePlayer = .player
        }
        startDefendPhase()
    }
    
    func checkForPotionActivationsPt1() {
        isAskingPlayerToActivate = false // just in case
        isAskingOpponentToActivate = false
        
        guard board.playerPotionBrewed || board.opponentPotionBrewed else {
            resumePhase()
            return
        }
        
        if activePlayer == .player {
            if board.playerPotionBrewed {
                isAskingPlayerToActivate = true
            } else { // board.opponentPotionBrewed must be true due to the guard statement above
                isAskingOpponentToActivate = true
            }
        } else {
            if board.opponentPotionBrewed{
                isAskingOpponentToActivate = true
            } else { // board.playerPotionBrewed must be true due to the guard statement above
                isAskingPlayerToActivate = true
            }
        }
        
        
    }
    
    func declinePotionActivations(for player: PlayerSide) {
        if player == .player {
            isAskingPlayerToActivate = false
        } else {
            isAskingOpponentToActivate = false
        }
        
        if player == activePlayer {
            checkForPotionActivationsPt2(player)
        } else {
            resumePhase()
        }
    }
    
    func checkForPotionActivationsPt2(_ player: PlayerSide){
        if player == .opponent { // Ask the person who didn't just respond
            if board.playerPotionBrewed {
                isAskingPlayerToActivate = true
            } else {
                resumePhase()
            }
        } else {
            if board.opponentPotionBrewed {
                isAskingOpponentToActivate = true
            } else {
                resumePhase()
            }
        }
    }
    
    func resumePhase() {
        switch phase {
        case .defend: endDefendPhasePt2(); return
        case .replenish: resolveReplenishPhasePt2(); return
        case .action: passFromActionPhasePt2(); return
        case .attack: passAttackPhasePt2(); return
        }
    }
    


    // MARK: - Card Monitor Registration

    private func registerMonitorsForCard(in slot: CardSlot) {
        guard !slot.card.isEmpty,
              let card = PresentedCardModel.cardByCode[slot.card] else { return }

        guard let def = CardEffects.registry[card.cardCode] else { return }

        def.registerMonitors?(slot, self)
    }
    
    func getOpponentBoard(matchCode: String, opponentID: String) /*-> [String: Any]*/ {
        if opponentID == "" {
           return //[:]
        }
        let databaseRef = Database.database().reference()
        let oppBoardRef = databaseRef.child("matches/\(matchCode)/\(opponentID)/board")
        
        let handler = oppBoardRef.observe(.value) {snapshot in
            if let snapshot = snapshot.value as? [String: Any] {
                DispatchQueue.main.async {
                    self.board.dictionaryToBoard(snapshot)
                }
            }
        }
    }
}

enum Phase: Int, Codable, Comparable {
    case defend, replenish, action, attack
    
    static func < (lhs: Phase, rhs: Phase) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
}

enum NonBoardZone: Codable, Comparable {
    case deck, hand, discard
}
