//
//  GameEngine.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 11/26/25.
//

import Foundation

final class GameEngine {

    var board: BoardModel
    var monitors: Monitors = Monitors()

    init(initialBoard: BoardModel = BoardModel()) {
        self.board = initialBoard
    }


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

        var ctx = BreakCardContext(source: slot, target: target)

        for entry in monitors.breakCard.entries where entry.step == .beforeBreak {
            entry.handler(&ctx, &board)
            if ctx.cancelled { return }
        }
        
        //break
        
        for entry in monitors.breakCard.entries where entry.step == .afterBreak {
            entry.handler(&ctx, &board)
            if ctx.cancelled { return }
        }

    }

    // MARK: - Card Monitor Registration

    private func registerMonitorsForCard(in slot: CardSlot) {
        guard !slot.card.isEmpty,
              let card = PresentedCardModel.cardByCode[slot.card] else { return }

        switch card.cardCode {

        case "FAS": // Aspect of Blaze
            monitors.addDealDamageMonitor(from: slot, step: .beforeDamage) { context, board in
                let current = board.slot(for: slot.owner, zone: slot.zone)
                guard current.card == slot.card else { return }
                guard context.source.owner == slot.owner else { return }
                context.amount *= 2
            }

        case "AAS": // Aspect of Breeze
            monitors.addGainAetherMonitor(from: slot, step: .beforeGain) { context, board in
                let current = board.slot(for: slot.owner, zone: slot.zone)
                guard current.card == slot.card else { return }
                guard context.player == slot.owner else { return }
                context.amount *= 2
            }

        case "EAS": // Aspect of Cavern
            monitors.addBreakCardMonitor(from: slot, step: .beforeBreak) { context, board in
                let current = board.slot(for: slot.owner, zone: slot.zone)
                guard current.card == slot.card else { return }

                guard context.target.owner == slot.owner,
                      let brokenCard = PresentedCardModel.cardByCode[context.target.card] else { return }

                let isEnchantmentOrItem = (brokenCard.type == .ward ||
                                           brokenCard.type == .charm ||
                                           brokenCard.type == .curse ||
                                           brokenCard.type == .relic ||
                                           brokenCard.type == .potion)
                guard isEnchantmentOrItem,
                      brokenCard.element == .EARTH else { return }

                context.cancelled = true
            }

        default:
            break
        }
    }
}
