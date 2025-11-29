//
//  GameEngine.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 11/26/25.
//
import Combine
import SwiftUI

final class GameEngine: ObservableObject {
    @Published var board: BoardModel
    @Published var phase: Phase
    @Published var activePlayer: PlayerSide
    @Published var isAskingToTurnPage: Bool
    var monitors: Monitors = Monitors()

    init(initialBoard: BoardModel = BoardModel(), playerFirst: PlayerSide, initialPhase: Phase, askingToTurnPage: Bool) {
        self.board = initialBoard
        
        self.activePlayer = playerFirst
        self.phase = initialPhase
        self.isAskingToTurnPage = askingToTurnPage
        
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
    
    
    // MARK: - Play Data Structures
    
    var AbilityStack: [Int: [CardEffect]]
    var AbilitySources: [Int: [CardSlot]]

    // MARK: - Game Actions
    
    func dealDamage(sourceOwner: PlayerSide, sourceZone: CardZone, target: PlayerSide, amount: Int) {
        let sourceSlot = board.slot(for: sourceOwner, zone: sourceZone)
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
        
        for entry in monitors.gainAether.entries where entry.step == .beforeGain {
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
    
    
    func playCard(fromHandIndex index: Int, owner: PlayerSide, as zone: CardZone, hand: inout [String]) {
        let cardCode = hand[index]
        guard let card = PresentedCardModel.cardByCode[cardCode] else { return }

        let slot = CardSlot(owner: owner, zone: zone, card: cardCode)
        
        if board.playerPotionBrewed || board.opponentPotionBrewed {
            // check with players (active then nonactive) to check for potion activations
            
            if phase == .action {
                resolveStack()
            }
        }

        switch card.type {
        case .jinx, .counterspell:
            playSnap(card: card, into: slot)
        case .curse, .ward, .charm, .relic, .potion:
            playPermanent(card: card, into: slot)
        }

        hand.remove(at: index)
        board.setHand(hand, owner: owner)
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
        for speed in 5...1 {
            if AbilityStack[speed]!.count > 0 {
                for i in 0..<AbilityStack[speed]!.count {
                    AbilityStack[speed]![i](AbilitySources[speed]![i], self)
                }
            }
        }
    }
    
    func incrementReplenishCounters() {
        switch activePlayer {
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
    
    // MARK: - Phase Handling
    
    func resolveDefendPhase() {
        resolveStack()
        cleanupSnapSpells()
        endDefendPhase()
    }
    
    func endDefendPhase() {
        if board.playerPotionBrewed || board.opponentPotionBrewed {
            // check with players (active then nonactive) to check for potion activations
        }
        phase = .replenish
        resolveReplenishPhase()
    }
    
    func resolveReplenishPhase() {
        gainAether(sourceOwner: activePlayer, for: activePlayer, amount: 1)
        incrementReplenishCounters()
        
        // check with active player to see if they'd like to turn the page
        
        if board.playerPotionBrewed || board.opponentPotionBrewed {
            // check with players (active then nonactive) to check for potion activations
        }
    }
    


    // MARK: - Card Monitor Registration

    private func registerMonitorsForCard(in slot: CardSlot) {
        guard !slot.card.isEmpty,
              let card = PresentedCardModel.cardByCode[slot.card] else { return }

        guard let def = CardEffects.registry[card.cardCode] else { return }

        def.registerMonitors?(slot, self)
    }
}

enum Phase: Codable {
    case defend, replenish, action, attack
}
