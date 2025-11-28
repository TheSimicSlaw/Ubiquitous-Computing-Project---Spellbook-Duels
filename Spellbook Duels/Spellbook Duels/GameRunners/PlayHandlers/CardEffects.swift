//
//  CardEffects.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 11/27/25.
//

import Foundation

typealias CardEffect = (_ slot: CardSlot, _ engine: GameEngine) -> Void

struct CardEffectDefinition {
    // Called when the card is played from hand (after moving it onto the board, but before phases continue)
    let onPlay: CardEffect?

    // Called when the card’s activated ability is used
    let onActivate: CardEffect?

    // Registers ongoing monitors while this card is on the field.
    let registerMonitors: CardEffect?

    let onEnterField: CardEffect?
    let onLeaveField: CardEffect?

    init(onPlay: CardEffect? = nil, onActivate: CardEffect? = nil, registerMonitors: CardEffect? = nil,
         onEnterField: CardEffect? = nil, onLeaveField: CardEffect? = nil) {
        self.onPlay = onPlay
        self.onActivate = onActivate
        self.registerMonitors = registerMonitors
        self.onEnterField = onEnterField
        self.onLeaveField = onLeaveField
    }
    
//    func resolveEffects(slot: CardSlot, gameEngine: GameEngine) {
//        onPlay?(slot, gameEngine)
//        onActivate?(slot, gameEngine)
//        onEnterField?(slot, gameEngine)
//        onLeaveField?(slot, gameEngine)
//    }
}

struct CardEffects {
    static func otherSide(side: PlayerSide) ->  PlayerSide {
        return (side == .player) ? .opponent : .player
    }
    
    static let registry: [String: CardEffectDefinition] = [

        // Aspect of Blaze – passive damage doubler
        "FAS": CardEffectDefinition(
            registerMonitors: { slot, engine in
                engine.monitors.addDealDamageMonitor(from: slot, step: .beforeDamage) { context, board in
                    let current = board.slot(for: slot.owner, zone: slot.zone)
                    guard current.card == slot.card else { return }
                    guard context.source.owner == slot.owner else { return }
                    context.amount *= 2
                }
            }
        ),
        
        // Aspect of Breeze - Aethergain doubler
        "AAS": CardEffectDefinition(
            registerMonitors: { slot, engine in
                engine.monitors.addGainAetherMonitor(from: slot, step: .beforeGain) { context, board in
                    let current = board.slot(for: slot.owner, zone: slot.zone)
                    guard current.card == slot.card else { return }
                    guard context.player == slot.owner else { return }
                    context.amount *= 2
                }
            }
        ),

        // Aspect of Cavern - Your earth enchantments and items cannot be broken.
        "EAS": CardEffectDefinition(
            registerMonitors: { slot, engine in
                engine.monitors.addBreakCardMonitor(from: slot, step: .beforeBreak) { context, board in
                    let current = board.slot(for: slot.owner, zone: slot.zone)
                    guard current.card == slot.card else { return }
                    
                    guard context.target.owner == slot.owner, let brokenCard = PresentedCardModel.cardByCode[context.target.card]
                    else { return }
                    
                    let isEnchantmentOrItem = !(brokenCard.type == .counterspell || brokenCard.type == .jinx)

                    guard isEnchantmentOrItem, brokenCard.element == .EARTH else { return }
                    context.cancelled = true
                }
            }
        ),

        // Purifying Fire – potion breaks curse & hits for 2
        "FPU": CardEffectDefinition(
            onActivate: { slot, engine in
                let owner = slot.owner
                let target: PlayerSide = otherSide(side: owner)
                
                let targetSlot: CardSlot = engine.board.slot(for: target, zone: .snap)
                engine.breakCard(sourceOwner: owner, zone: .snap, target: targetSlot)

                engine.dealDamage(
                    sourceOwner: owner,
                    sourceZone: slot.zone,
                    target: target,
                    amount: 2
                )
            }
        ),

        // Bottled Fortitude – potion prevents next Attack spell damage
        "EBO": CardEffectDefinition(
            onActivate: { slot, engine in
                let owner = slot.owner
                
                engine.monitors.addLoseAetherMonitor(from: slot, step: .beforeLose) { context, board in
                    guard context.player == owner,
                          let sourceCard = PresentedCardModel.cardByCode[context.source.card],
                          sourceCard.type == .jinx || sourceCard.type == .curse else { return }

                    context.cancelled = true
                    engine.monitors.removeAllMonitors(for: slot)
                }
            }
        )
    ]
}
