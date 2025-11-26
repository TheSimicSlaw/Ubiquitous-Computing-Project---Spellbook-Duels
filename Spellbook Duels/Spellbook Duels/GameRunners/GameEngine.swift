//
//  GameEngine.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 11/26/25.
//

import Foundation

final class GameEngine {

    var board: BoardModel
    var monitors: Monitors

    init(initialBoard: BoardModel = BoardModel()) {
        self.board = initialBoard
        self.monitors = Monitors()
    }


    // MARK: - Game Actions

    func gainAether(for player: PlayerSide, amount: Int) {
        var context = GainAetherContext(player: player, amount: amount)

        // Run all gain-aether monitors in insertion order
        for entry in monitors.gainAether.entries {
            entry.handler(&context, &board)
            if context.cancelled { return }
        }

        switch context.player {
        case .player:   board.playerAetherTotal   += context.amount
        case .opponent: board.opponentAetherTotal += context.amount
        }
    }

    func dealDamage(sourceOwner: PlayerSide, sourceZone: CardZone, target: PlayerSide, amount: Int) {
        let sourceSlot = board.slot(for: sourceOwner, zone: sourceZone)
        guard !sourceSlot.card.isEmpty else { return }

        var ctx = DealDamageContext(source: sourceSlot, target: target, amount: amount)

        // STEP 0: beforeDamage monitors (Blaze, prevention, redirection, etc.)
        for entry in monitors.dealDamage.entries where entry.step == .beforeDamage {
            entry.handler(&ctx, &board)
            if ctx.cancelled { return }
        }

        // APPLY DAMAGE
        switch ctx.target {
        case .player:   board.playerAetherTotal   -= ctx.amount
        case .opponent: board.opponentAetherTotal -= ctx.amount
        }

        // STEP 1: afterDamage monitors (triggers that care after damage is dealt)
        for entry in monitors.dealDamage.entries where entry.step == .afterDamage {
            entry.handler(&ctx, &board)
            if ctx.cancelled { break }
        }
    }

    func breakCard(at owner: PlayerSide, zone: CardZone) {
        let slot = board.slot(for: owner, zone: zone)
        guard !slot.card.isEmpty else { return }

        var ctx = BreakCardContext(target: slot)

        // Run all break-card monitors
        for entry in monitors.breakCard.entries {
            entry.handler(&ctx, &board)
            if ctx.cancelled { return }  // e.g. Cavern protecting something
        }

    }

    // MARK: - Turn / counters (stub for you to expand)

    func endTurn(for currentPlayer: PlayerSide) {
        // Example: tick time counters, brew counters, etc.
        // You can expand this to implement your duration/brew logic.
        if currentPlayer == .player {
            if let c = board.playerCurseTimeCounters {
                board.playerCurseTimeCounters = max(0, c - 1)
            }
            if let w = board.playerWardTimeCounters {
                board.playerWardTimeCounters = max(0, w - 1)
            }
            if let ch = board.playerCharmTimeCounters {
                board.playerCharmTimeCounters = max(0, ch - 1)
            }
            if let b = board.playerPotionBrewCounters {
                board.playerPotionBrewCounters = b + 1
            }
        } else {
            if let c = board.opponentCurseTimeCounters {
                board.opponentCurseTimeCounters = max(0, c - 1)
            }
            if let w = board.opponentWardTimeCounters {
                board.opponentWardTimeCounters = max(0, w - 1)
            }
            if let ch = board.opponentCharmTimeCounters {
                board.opponentCharmTimeCounters = max(0, ch - 1)
            }
            if let b = board.opponentPotionBrewCounters {
                board.opponentPotionBrewCounters = b + 1
            }
        }

        // You can also drop expired duration cards here by checking counters,
        // and then calling `breakCard` for them.
    }

    // MARK: - Card → monitor wiring

    /// Given a slot that just gained a card, attach its monitors.
    private func registerMonitorsForCard(in slot: CardSlot) {
        guard !slot.card.isEmpty,
              let card = PresentedCardModel.cardByCode[slot.card] else { return }

        switch card.cardCode {

        // Aspect of Blaze: If you would deal damage, double it instead.
        case "FAS":
            monitors.addDealDamageMonitor(from: slot, step: .beforeDamage) { ctx, board in
                // Card must still be on the field in that slot
                let current = board.slot(for: slot.owner, zone: slot.zone)
                guard current.card == slot.card else { return }
                // Only affects damage dealt by that player
                guard ctx.source.owner == slot.owner else { return }
                ctx.amount *= 2
            }

        // Aspect of Breeze: If you would gain aether, gain twice that instead.
        case "AAS":
            monitors.addGainAetherMonitor(from: slot) { ctx, board in
                let current = board.slot(for: slot.owner, zone: slot.zone)
                guard current.card == slot.card else { return }
                guard ctx.player == slot.owner else { return }
                ctx.amount *= 2
            }

        // Aspect of Cavern: your Earth enchantments/items can't be broken.
        case "EAS":
            monitors.addBreakCardMonitor(from: slot) { ctx, board in
                let current = board.slot(for: slot.owner, zone: slot.zone)
                guard current.card == slot.card else { return }

                // Check: same owner, target is an Earth enchantment/item.
                guard ctx.target.owner == slot.owner,
                      let brokenCard = PresentedCardModel.cardByCode[ctx.target.card] else { return }

                // "Enchantment" in your design is basically Wards + Charms + Relics?
                let isEnchantmentOrItem = (brokenCard.type == .ward ||
                                           brokenCard.type == .charm ||
                                           brokenCard.type == .relic)
                guard isEnchantmentOrItem,
                      brokenCard.element == .EARTH else { return }

                ctx.cancelled = true
            }

        default:
            break
        }
    }
}
