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
    
    private static func isEnchantment(_ type: CardType) -> Bool {
            switch type {
            case .curse, .ward, .charm:
                return true
            default:
                return false
            }
        }

        private static func isItem(_ type: CardType) -> Bool {
            switch type {
            case .relic, .potion:
                return true
            default:
                return false
            }
        }
        
        private static func isSpell(_ type: CardType) -> Bool {
            // Everything that isn't an item
            switch type {
            case .relic, .potion:
                return false
            default:
                return true
            }
        }

        private static func countEnchantmentsAndItems(for owner: PlayerSide,
                                                      in board: BoardModel) -> Int {
            var slots: [CardSlot] = []
            switch owner {
            case .player:
                slots = [board.playerCurse, board.playerWard, board.playerCharm,
                         board.playerRelic, board.playerPotion]
            case .opponent:
                slots = [board.opponentCurse, board.opponentWard, board.opponentCharm,
                         board.opponentRelic, board.opponentPotion]
            }

            var count = 0
            for slot in slots {
                guard !slot.card.isEmpty,
                      let card = PresentedCardModel.cardByCode[slot.card] else { continue }
                if isEnchantment(card.type) || isItem(card.type) {
                    count += 1
                }
            }
            return count
        }
    
    static let registry: [String: CardEffectDefinition] = [
        
        // MARK: - Charms

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
        
        // Stoking the Flames — “You gain 3 aether each turn instead of 1. If at the end of your turn you have not played a new attack spell, break this charm.”
        "FST": CardEffectDefinition(
            registerMonitors: { slot, engine in
                // Turn aether → 3 instead of 1
                engine.monitors.addGainAetherMonitor(from: slot, step: .beforeGain) { context, board in
                    let current = board.slot(for: slot.owner, zone: slot.zone)
                    guard current.card == slot.card else { return }
                    guard context.player == slot.owner else { return }

                    // Heuristic: normal turn gain is 1
                    guard context.amount == 1 else { return }
                    context.amount = 3
                }

                // MARK: TODO: track “played a new attack spell this turn” and, on end-of-turn,
                // break this charm if none were played. This will need either:
                // - a turn/phase-end hook, or
                // - state on GameEngine that is ticked and checked when the active player changes.
            }
        ),

        // Aspect of Tide — “At the end of your action phase, put a wave counter on this spell and on each of your enchantments that have wave counters on them. When this spell fades or breaks, discard your hand and draw a card for each wave counter on it.”
        "WAS": CardEffectDefinition(
            registerMonitors: { slot, engine in
                // Implement the "when this fades or breaks" part using discard-from-field.
                engine.monitors.addDiscardFromFieldMonitor(from: slot, step: .afterDiscardFromField) { context, board in
                    guard context.card.owner == slot.owner,
                          context.card.zone == slot.zone,
                          context.card.card == slot.card else { return }

                    let waveCount = context.card.counters[Counter.wave] ?? 0
                    guard waveCount > 0 else { return }

                    let owner = slot.owner
                    let hand = board.getHand(owner: owner)

                    if !hand.isEmpty {
                        engine.cardsToDiscard(hand, from: hand, source: .hand, player: owner)
                    }

                    engine.drawNCards(waveCount, player: owner)
                }

                // MARK: TODO: we still need an explicit “end of your action phase” hook to implement the
                // counter-adding text properly.
            }
        ),

        // Wall Reinforcement – **needs strength modifiers + per-damage tracking** “Enters with 6 stone counters. Whenever you take aether damage, remove a stone counter.  Wards you have gain 1 strength for each stone counter on this spell.”
        "EWA": CardEffectDefinition(
            registerMonitors: { slot, engine in
                // MARK: TODO:
                // - On enter field: set slot.counters["stone"] = 6.
                // - On afterLoseAether where player == slot.owner: decrement stone.
                // - Use StrengthModifierStore to give +stone strength to wards.
                //
                // Right now StrengthModifierStore is only referenced inside StrengthGetters and not
                // threaded through GameEngine, so this one needs a small structural change before
                // we can implement it cleanly.
            }
        ),

        // Meditation – Air spells cost 2 less
        "AME": CardEffectDefinition(
            registerMonitors: { slot, engine in
                engine.monitors.addPayAetherMonitor(from: slot, step: .beforePay) { context, board in
                    let current = board.slot(for: slot.owner, zone: slot.zone)
                    guard current.card == slot.card else { return }

                    guard context.player == slot.owner else { return }

                    guard let spell = PresentedCardModel.cardByCode[context.card] else { return }

                    guard CardEffects.isSpell(spell.type),
                          spell.element == .AIR else { return }

                    context.cost = max(context.cost - 2, 0)
                }
            }
        ),
        
        // MARK: - Potions

        // Purifying Fire – breaks curse & hits for 2
        "FPU": CardEffectDefinition(
            onActivate: { slot, engine in
                let owner = slot.owner
                let target: PlayerSide = otherSide(side: owner)
                
                let targetSlot: CardSlot = engine.board.slot(for: target, zone: .curse)
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
        ),
        
        // Breath of Fresh Air – "You gain 4 aether."
        "ABR": CardEffectDefinition(
            onActivate: { slot, engine in
                let owner = slot.owner
                engine.gainAether(sourceOwner: owner, for: owner, amount: 4)
            }
        ),
        
        // MARK: - Relics

        // Steel Shield
        // “While you have no defense spells, aether damage dealt to you is halved (round down).”
        "EST": CardEffectDefinition(
            registerMonitors: { slot, engine in
                engine.monitors.addLoseAetherMonitor(from: slot, step: .beforeLose) { context, board in
                    let current = board.slot(for: slot.owner, zone: slot.zone)
                    guard current.card == slot.card else { return }
                    guard context.player == slot.owner else { return }

                    // “Defense spells” → ward or snap on your side.
                    let ward = board.slot(for: slot.owner, zone: .ward)
                    let snap = board.slot(for: slot.owner, zone: .snap)
                    let hasDefense = !ward.card.isEmpty || !snap.card.isEmpty
                    guard !hasDefense else { return }

                    context.amount /= 2
                }
            }
        ),

        // Bonecracker
        // “An opponent that attacked you this turn takes 3 aether damage.”
        "EON": CardEffectDefinition(
            onActivate: { slot, engine in
                let opponent = Self.otherSide(side: slot.owner)

                guard engine.board.previousPlayerIsAttacking else { return }

                engine.dealDamage(sourceOwner: slot.owner, sourceZone: slot.zone, target: opponent, amount: 3)
            }
        ),

        // Seer’s Scrying Bowl
        "WSE": CardEffectDefinition( // transfer from PlayerDeckView
            onActivate: { slot, engine in
                // MARK: TODO:
                //   “Pay 1 aether to look at the top 3 cards of your spellbook any time you have priority” is mostly a UI thing
                //   * pay 1 aether (engine.loseAether)
                //   * expose the top 3 deck cards to the local player
                //   * no game-state change beyond that.
            }
        ),

        // Earth Wand – Earth wards / counterspells get +3 strength
        "EEA": CardEffectDefinition(
            registerMonitors: { slot, engine in
                // MARK: TODO:
                // Needs a way to plug into StrengthGetters / StrengthModifierStore so it adds +3 when
                // - owner == slot.owner
                // - card.element == .EARTH
                // - card.type == .ward || .counterspell
            }
        ),

        // Fire Wand – “Whenever you cast a Fire spell, each opponent loses 1 aether.”
        "FFI": CardEffectDefinition(
            registerMonitors: { slot, engine in
                engine.monitors.addPlayCardMonitor(from: slot, step: .afterPlay) { context, board in
                    let current = board.slot(for: slot.owner, zone: slot.zone)
                    guard current.card == slot.card else { return }

                    guard context.slot.owner == slot.owner,
                          let played = PresentedCardModel.cardByCode[context.card]
                    else { return }

                    guard Self.isSpell(played.type), played.element == .FIRE else { return }

                    let opp = Self.otherSide(side: slot.owner)
                    engine.dealDamage(
                        sourceOwner: slot.owner,
                        sourceZone: slot.zone,
                        target: opp,
                        amount: 1
                    )
                }
            }
        ),

        // Water Wand – “Whenever you cast a Water enchantment, you gain 3 aether.”
        "WWA": CardEffectDefinition(
            registerMonitors: { slot, engine in
                engine.monitors.addPlayCardMonitor(from: slot, step: .afterPlay) { context, board in
                    let current = board.slot(for: slot.owner, zone: slot.zone)
                    guard current.card == slot.card else { return }

                    guard context.slot.owner == slot.owner,
                          let played = PresentedCardModel.cardByCode[context.card]
                    else { return }

                    guard Self.isEnchantment(played.type), played.element == .WATER else { return }

                    engine.gainAether(
                        sourceOwner: slot.owner,
                        for: slot.owner,
                        amount: 3
                    )
                }
            }
        ),

        // Air Wand – “Whenever you cast an Air spell, you gain 3 aether.”
        "AAI": CardEffectDefinition(
            registerMonitors: { slot, engine in
                engine.monitors.addPlayCardMonitor(from: slot, step: .afterPlay) { context, board in
                    let current = board.slot(for: slot.owner, zone: slot.zone)
                    guard current.card == slot.card else { return }

                    guard context.slot.owner == slot.owner,
                          let played = PresentedCardModel.cardByCode[context.card]
                    else { return }

                    guard Self.isSpell(played.type), played.element == .AIR else { return }

                    engine.gainAether(
                        sourceOwner: slot.owner,
                        for: slot.owner,
                        amount: 3
                    )
                }
            }
        ),

        // Wall Spikes
        // “Your Earth wards have +2 strength, and when your opponent deals damage to you with a
        //  jinx, that player takes 2 aether damage and you destroy this relic.”
        "ELL": CardEffectDefinition(
            registerMonitors: { slot, engine in
                // MARK: TODO: +2 strength to Earth wards via StrengthModifierStore.

                // Retaliation part
                engine.monitors.addLoseAetherMonitor(from: slot, step: .afterLose) { context, board in
                    let current = board.slot(for: slot.owner, zone: slot.zone)
                    guard current.card == slot.card else { return }
                    guard context.player == slot.owner else { return }

                    guard let srcCard = PresentedCardModel.cardByCode[context.source.card],
                          srcCard.type == .jinx,
                          context.amount > 0
                    else { return }

                    let attacker = context.source.owner

                    // Deal 2 back
                    engine.dealDamage(
                        sourceOwner: slot.owner,
                        sourceZone: slot.zone,
                        target: attacker,
                        amount: 2
                    )

                    // Destroy this relic
                    engine.discardFromField(slot: current)
                }
            }
        ),

        // Kindling Staff – “Deal 3 damage to each opponent without a ward.”
        "FKI": CardEffectDefinition(
            onActivate: { slot, engine in
                let owner = slot.owner
                let opp = Self.otherSide(side: owner)
                let theirWard = engine.board.slot(for: opp, zone: .ward)

                guard theirWard.card.isEmpty else { return }

                engine.dealDamage(
                    sourceOwner: owner,
                    sourceZone: slot.zone,
                    target: opp,
                    amount: 3
                )
            }
        ),

        // Wax Wings
        // “Prevent any damage you would take from non-Fire sources until the end of your next turn.”
        "AWA": CardEffectDefinition(
            registerMonitors: { slot, engine in
                engine.monitors.addLoseAetherMonitor(from: slot, step: .beforeLose) { context, board in
                    let current = board.slot(for: slot.owner, zone: slot.zone)
                    guard current.card == slot.card else { return }
                    guard context.player == slot.owner else { return }

                    guard let src = PresentedCardModel.cardByCode[context.source.card] else { return }
                    guard src.element != .FIRE else { return }

                    // MARK: TODO: this currently lasts as long as the relic is on the field.
                    // To match “until end of your next turn” exactly, we’d need a turn-end hook
                    // that discards this or disables its monitor.
                    context.cancelled = true
                }
            }
        ),
        
        // MARK: - Potions
        
        // Instant Freeze
        // “All spells and abilities that have been cast or activated before this potion is
        //  activated have no effect. This ability resolves first. Players cannot activate abilities
        //  after this potion is activated.”
        "WIN": CardEffectDefinition(
            onActivate: { slot, engine in
                // This ability already resolves first because it has speed 5 and your
                // resolveStack resolves from 5 down to 1.
                
                // Clear all other abilities currently on the stack.
                engine.resetStackAndSources()

                // MARK: TODO: “Players cannot activate abilities after this potion is activated.”
                // To support this perfectly, you’d want a flag on GameEngine like
                // `abilitiesLockedForTurn` that activatePotion/activateRelic check.
            }
        ),

        // Bottled Fortitude – already in your code; kept unchanged.
        // “The next time you would take damage from an Attack spell, prevent that damage.”
        "EBO": CardEffectDefinition(
            onActivate: { slot, engine in
                let owner = slot.owner

                engine.monitors.addLoseAetherMonitor(from: slot, step: .beforeLose) { context, board in
                    guard context.player == owner,
                          let sourceCard = PresentedCardModel.cardByCode[context.source.card],
                          sourceCard.type == .jinx || sourceCard.type == .curse
                    else { return }

                    context.cancelled = true
                    engine.monitors.removeAllMonitors(for: slot)
                }
            }
        ),

        // Jar of Dirt
        // “The next time you would take aether damage, prevent that damage.”
        "EJA": CardEffectDefinition(
            onActivate: { slot, engine in
                let owner = slot.owner

                engine.monitors.addLoseAetherMonitor(from: slot, step: .beforeLose) { context, board in
                    guard context.player == owner else { return }

                    context.cancelled = true
                    engine.monitors.removeAllMonitors(for: slot)
                }
            }
        ),

        // Sleeping Draught
        // “The next opponent cannot play spells until the end of their next turn.”
        "WSL": CardEffectDefinition(
            onActivate: { slot, engine in
                // MARK: TODO:
                // Needs:
                // - state on GameEngine to remember “next opponent” and duration,
                // - a PlayCardMonitor.beforePlay that cancels their spells,
                // - a turn-end hook to clear the effect.
            }
        ),

        // Building Crescendo — “Whenever you gain aether, put that many wave counters on Building Crescendo. When this spell fades or breaks, you gain 2 aether for each wave counter on it.”
        "WBU": CardEffectDefinition(
            registerMonitors: { slot, engine in
                // Gain → wave counters
                engine.monitors.addGainAetherMonitor(from: slot, step: .afterGain) { context, board in
                    let current = board.slot(for: slot.owner, zone: slot.zone)
                    guard current.card == slot.card else { return }
                    guard context.player == slot.owner else { return }
                    guard context.amount > 0 else { return }

                    var updated = current
                    let existing = updated.counters[.wave] ?? 0
                    updated.counters[.wave] = existing + context.amount
                    board.setSlot(updated)
                }

                // On fade/break
                engine.monitors.addDiscardFromFieldMonitor(from: slot, step: .afterDiscardFromField) { context, board in
                    guard context.card.owner == slot.owner,
                          context.card.zone == slot.zone,
                          context.card.card == slot.card
                    else { return }

                    let wave = context.card.counters[.wave] ?? 0
                    guard wave > 0 else { return }

                    engine.gainAether(
                        sourceOwner: slot.owner,
                        for: slot.owner,
                        amount: 2 * wave
                    )
                }
            }
        ),

        // Purifying Fire – already present in your code; kept as-is.
        "FPU": CardEffectDefinition(
            onActivate: { slot, engine in
                let owner = slot.owner
                let targetSide: PlayerSide = otherSide(side: owner)

                let targetSlot: CardSlot = engine.board.slot(for: targetSide, zone: .curse)
                engine.breakCard(sourceOwner: owner, zone: .snap, target: targetSlot)

                engine.dealDamage(
                    sourceOwner: owner,
                    sourceZone: slot.zone,
                    target: targetSide,
                    amount: 2
                )
            }
        ),

        // Flask-Held Gale
        // “Break a Ward. Gain aether equal to that card’s cost.”
        "AFL": CardEffectDefinition(
            onActivate: { slot, engine in
                // MARK: TODO:
                // Properly this needs a targeting system so the activating player can choose any
                // ward in play. Once you have something like `engine.pendingTargets: [CardSlot]`,
                // you can:
                //   - read the chosen ward slot,
                //   - look up its cost,
                //   - gain that much aether,
                //   - break it.
            }
        ),

        // Breath of Fresh Air – already present.
        "ABR": CardEffectDefinition(
            onActivate: { slot, engine in
                let owner = slot.owner
                engine.gainAether(sourceOwner: owner, for: owner, amount: 4)
            }
        ),

        // Waves of Aged Wine
        // “Each opponent loses life equal to the number of wave counters on this card.
        //  Passive: Whenever you put a brew counter on this potion, put a wave counter on it.”
        "WAV": CardEffectDefinition(
            onActivate: { slot, engine in
                let owner = slot.owner
                let opp = Self.otherSide(side: owner)
                let wave = slot.counters[.wave] ?? 0
                guard wave > 0 else { return }

                engine.dealDamage(
                    sourceOwner: owner,
                    sourceZone: slot.zone,
                    target: opp,
                    amount: wave
                )
            }
            // MARK: TODO:
            // hook brew-counter increments (from BoardModel.playerPotionBrewCounters / opponentPotionBrewCounters or similar) into “put a wave counter on this card”.
        ),

        // MARK: - Jinxes / Attack / Misc

        // Sparking Projectile – needs a hook in ward-damage resolution
        "FSP": CardEffectDefinition(
            registerMonitors: { slot, engine in
                // MARK: TODO:
                // “Wards cannot reduce the damage your attack spells deal” requires
                // a place where ward strength is applied vs jinx strength. Once that logic
                // is centralized, we can add a monitor or strength override here.
            }
        ),

        // Greek Fire
        // “Each opponent takes 4 aether damage for each enchantment and each item they control.”
        "FGR": CardEffectDefinition(
            onActivate: { slot, engine in
                let owner = slot.owner
                let opp = Self.otherSide(side: owner)

                let count = Self.countEnchantmentsAndItems(for: opp, in: engine.board)
                guard count > 0 else { return }

                engine.dealDamage(
                    sourceOwner: owner,
                    sourceZone: slot.zone,
                    target: opp,
                    amount: 4 * count
                )
            }
        ),

        // Aetherblaze – needs “choose N” infrastructure
        "AAE": CardEffectDefinition(
            onPlay: { slot, engine in
                // MARK: TODO:
                // “Each opponent who has a charm loses N aether (round up). They can’t lose more
                // than 6 aether this way.” N is the chosen value of X in cost “N Aether”.
                // This needs: a way to store the chosen N for this cast, then apply min(N, 6) when resolving.
            }
        ),

        // Twister’s Gale – needs multi-target selection & chosen N
        "ATW": CardEffectDefinition(
            onPlay: { slot, engine in
                // MARK: TODO:
                // Requires:
                //  - variable N from cost, (got this)
                //  - selection of up to N item CardSlots from the UI, (got this
                //  - then pull them to hand & apply aether loss per item.
            }
        ),

        // Drown – strength depends on counters across all your cards
        "WDR": CardEffectDefinition(
            registerMonitors: { slot, engine in
                // MARK: TODO:
                // Hook this into StrengthGetters so that when computing strength for WDR,
                // we count "age", "brew", and "wave" counters on all permanents you control.
            }
        ),

        // Immolate – “If you do not win the game during the defend phase this card resolves in,
        // you lose the game.”
        "FIM": CardEffectDefinition(
            onPlay: { slot, engine in
                // MARK: TODO:
                // Needs game-end state and a way to mark “this defend phase has an active
                // Immolate; if game not won by endDefendPhasePt2, the caster loses.”
            }
        ),

        // Counterburn – depends on prior Water counterspell
        "FOU": CardEffectDefinition(
            onPlay: { slot, engine in
                // MARK: TODO:
                // “If you played a Water counterspell this turn, double this card’s strength.”
                // Needs some per-turn state like:
                //   engine.hasCastWaterCounterspellThisTurn[owner]
                // updated by a PlayCardMonitor when Water counterspells are cast.
            }
        ),

        // Toxic Fog – stopping gain and taxing spells
        "ANT": CardEffectDefinition(
            registerMonitors: { slot, engine in
                // MARK: TODO:
                // “An opponent dealt aether damage by this spell cannot gain aether until the
                // end of their turn. For that duration, spells they cast cost 1 more aether.”
                // Needs:
                //  - flagging “this opponent has Toxic Fog on them until end of turn”,
                //  - a GainAetherMonitor to cancel their gains,
                //  - a PlayCardMonitor to tax their spell costs,
                //  - and a turn-end hook to clear.
            }
        ),

        // Unfriendly Skies
        "AUN": CardEffectDefinition(
            registerMonitors: { slot, engine in
                // MARK: TODO:
                // “Whenever an opponent activates an item, that player may discard a card.
                //  If they do not, break a Ward they control and you gain 2 aether.”
                // Needs:
                //  - an activation hook around activateRelic/activatePotion that passes the
                //    actor and the slot,
                //  - player choice (discard vs break),
                //  - selection of which ward to break.
            }
        ),

        // Stray Gust
        "AST": CardEffectDefinition(
            onPlay: { slot, engine in
                // MARK: TODO:
                // “Defending opponent pulls a spell or item they have to their hand.”
                // Needs:
                //  - targeting of which spell/item to pull.
            }
        ),

        // Howl
        "AHO": CardEffectDefinition(
            onPlay: { slot, engine in
                // MARK: TODO:
                // “Defending player pulls N spells and items to their hand, where N is the
                // amount of aether you have gained the turn this was cast.”
                // Needs:
                //  - per-turn aether-gain tracking per player,
                //  - UI-driven selection of which permanents to pull.
            }
        ),

        // Fireball / Scorched Soul / etc that depend on “N Aether” cost
        "FIR": CardEffectDefinition(
            onPlay: { slot, engine in
                // MARK: TODO:
                // This is your generic variable-cost burn spell.
                // Needs a place to store the chosen N on cast and apply that as damage.
            }
        ),

        "FCO": CardEffectDefinition(
            onPlay: { slot, engine in
                // MARK: TODO:
                // “When you cast this spell, you may break a charm. If you do, that charm’s
                // controller takes ½·N damage.”
                // Needs both:
                //  - chosen N from cost,
                //  - charm target selection.
            }
        ),

        // MARK: - Counterspells

        // Gale Force Deflection
        // “All damage that would be dealt to you this defense phase is dealt to the attacking
        //  opponent instead.”
        "AGA": CardEffectDefinition(
            registerMonitors: { slot, engine in
                engine.monitors.addLoseAetherMonitor(from: slot, step: .beforeLose) { context, board in
                    let current = board.slot(for: slot.owner, zone: slot.zone)
                    guard current.card == slot.card else { return }
                    guard context.player == slot.owner else { return }

                    guard engine.phase == .defend, board.previousPlayerIsAttacking else { return }

                    let dmg = context.amount
                    guard dmg > 0 else { return }

                    context.cancelled = true

                    let attacker = Self.otherSide(side: slot.owner)
                    engine.dealDamage(
                        sourceOwner: context.source.owner,
                        sourceZone: context.source.zone,
                        target: attacker,
                        amount: dmg
                    )
                }
            }
        ),

        // Insurmountable – “Prevent all damage that would be dealt to you this turn.”
        "EIN": CardEffectDefinition(
            registerMonitors: { slot, engine in
                engine.monitors.addLoseAetherMonitor(from: slot, step: .beforeLose) { context, board in
                    let current = board.slot(for: slot.owner, zone: slot.zone)
                    guard current.card == slot.card else { return }
                    guard context.player == slot.owner else { return }

                    context.cancelled = true
                    // Snap spells get cleaned up at the end of the defend phase by your
                    // cleanupSnapSpells → discardFromField, which will also clear monitors.
                }
            }
        ),

        // Refraction Mirage
        // Heads → prevent all damage this phase; tails → prevent half (round down prevented).
        "WRE": CardEffectDefinition(
            registerMonitors: { slot, engine in
                let isHeads = Bool.random()

                engine.monitors.addLoseAetherMonitor(from: slot, step: .beforeLose) { context, board in
                    let current = board.slot(for: slot.owner, zone: slot.zone)
                    guard current.card == slot.card else { return }
                    guard context.player == slot.owner else { return }

                    if isHeads {
                        context.cancelled = true
                    } else {
                        // prevent half (rounded down), so remaining damage = ceil(n/2)
                        let prevented = context.amount / 2
                        context.amount -= prevented
                    }
                }
            }
        ),

        // Blazing Counter – “The attacking opponent takes 3 aether damage.”
        "FBL": CardEffectDefinition(
            onPlay: { slot, engine in
                let owner = slot.owner
                let opp = Self.otherSide(side: owner)

                engine.dealDamage(
                    sourceOwner: owner,
                    sourceZone: slot.zone,
                    target: opp,
                    amount: 3
                )
            }
        ),

        // Countergale – “Prevent half the damage you would take this defense phase (round up prevented).”
        "ACO": CardEffectDefinition(
            registerMonitors: { slot, engine in
                engine.monitors.addLoseAetherMonitor(from: slot, step: .beforeLose) { context, board in
                    let current = board.slot(for: slot.owner, zone: slot.zone)
                    guard current.card == slot.card else { return }
                    guard context.player == slot.owner else { return }

                    // Damage taken = floor(n/2) (prevent half, rounded up).
                    context.amount /= 2
                }
            }
        ),

        // Hurried Wall / Quick Counterblaze / Air-Burst Dodge – pure stats/flavor
        "EHU": CardEffectDefinition(),
        "FQU": CardEffectDefinition(),
        "AIR": CardEffectDefinition(),

        // Icy Defense – depends on attacker’s element inside block resolution
        "WIC": CardEffectDefinition(
            registerMonitors: { _, _ in
                // MARK: TODO:
                // “Blocks 1 less damage from Fire spells” wants to adjust effective ward
                // strength when the attack is Fire. That requires an explicit place where
                // you compute “damage blocked by this counterspell” given attacker element.
            }
        ),

        // Scorching Rebuke
        // “At the end of the defend phase, the opponent who attacked you takes aether damage
        //  equal to the damage dealt to you this turn.”
        "FSC": CardEffectDefinition(
            registerMonitors: { slot, engine in
                // Track damage dealt to you while this spell is up.
                engine.monitors.addLoseAetherMonitor(from: slot, step: .afterLose) { context, board in
                    let current = board.slot(for: slot.owner, zone: slot.zone)
                    guard current.card == slot.card else { return }
                    guard context.player == slot.owner else { return }
                    guard context.amount > 0 else { return }

                    var updated = current
                    let total = updated.counters[.rebukeDamage] ?? 0
                    updated.counters[.rebukeDamage] = total + context.amount
                    board.setSlot(updated)
                }

                // When this snap is discarded at the end of the defend phase, fire back.
                engine.monitors.addDiscardFromFieldMonitor(from: slot, step: .afterDiscardFromField) { context, board in
                    guard context.card.owner == slot.owner,
                          context.card.zone == slot.zone,
                          context.card.card == slot.card else { return }

                    let stored = context.card.counters[.rebukeDamage] ?? 0
                    guard stored > 0 else { return }

                    let owner = slot.owner
                    let opp = Self.otherSide(side: owner)

                    engine.dealDamage(
                        sourceOwner: owner,
                        sourceZone: slot.zone,
                        target: opp,
                        amount: stored
                    )
                }
            }
        ),

        // Deflecting Gust
        // “At the end of the defend phase, the opponent who attacked you takes damage equal to
        //  the damage blocked by this spell.”  (Needs block computation hook.)
        "ADE": CardEffectDefinition(
            registerMonitors: { slot, engine in
                // MARK: TODO:
                // Similar to F S C, but we need “blocked damage by this spell”, not “damage
                // actually dealt to you”. That requires exposing the “blocked amount” in your
                // defense-resolution logic.
            }
        ),

        // Hide
        // “If you have 3 or less Aether, you take no damage this round.”
        "EHI": CardEffectDefinition(
            registerMonitors: { slot, engine in
                engine.monitors.addLoseAetherMonitor(from: slot, step: .beforeLose) { context, board in
                    let current = board.slot(for: slot.owner, zone: slot.zone)
                    guard current.card == slot.card else { return }
                    guard context.player == slot.owner else { return }

                    let currentAether: Int = (slot.owner == .player) ? board.playerAetherTotal : board.opponentAetherTotal
                    guard currentAether <= 3 else { return }

                    context.cancelled = true
                }
            }
        ),

        // MARK: - Wards / Curses / Other Permanents

        // Mud Vortex
        // “Prevent all aether damage you would be dealt by Fire or Water spells.”
        "EMU": CardEffectDefinition(
            registerMonitors: { slot, engine in
                engine.monitors.addLoseAetherMonitor(from: slot, step: .beforeLose) { context, board in
                    let current = board.slot(for: slot.owner, zone: slot.zone)
                    guard current.card == slot.card else { return }
                    guard context.player == slot.owner else { return }

                    guard let src = PresentedCardModel.cardByCode[context.source.card] else { return }
                    guard src.element == .FIRE || src.element == .WATER else { return }

                    context.cancelled = true
                }
            }
        ),

        // Retaliatory Wave
        // “Whenever you are dealt damage by an opponent, put that many wave counters on
        //  Retaliatory Wave. When this spell fades or breaks, it deals 1 damage per wave counter
        //  to each opponent.”
        "WET": CardEffectDefinition(
            registerMonitors: { slot, engine in
                // Track damage → wave counters
                engine.monitors.addLoseAetherMonitor(from: slot, step: .afterLose) { context, board in
                    let current = board.slot(for: slot.owner, zone: slot.zone)
                    guard current.card == slot.card else { return }
                    guard context.player == slot.owner else { return }
                    guard context.amount > 0 else { return }

                    // Only from the opponent
                    guard context.source.owner == Self.otherSide(side: slot.owner) else { return }

                    var updated = current
                    let existing = updated.counters[.wave] ?? 0
                    updated.counters[.wave] = existing + context.amount
                    board.setSlot(updated)
                }

                // On fade/break, deal damage equal to wave counters
                engine.monitors.addDiscardFromFieldMonitor(from: slot, step: .afterDiscardFromField) { context, board in
                    guard context.card.owner == slot.owner,
                          context.card.zone == slot.zone,
                          context.card.card == slot.card else { return }

                    let wave = context.card.counters[.wave] ?? 0
                    guard wave > 0 else { return }

                    let owner = slot.owner
                    let opp = Self.otherSide(side: owner)

                    engine.dealDamage(
                        sourceOwner: owner,
                        sourceZone: slot.zone,
                        target: opp,
                        amount: wave
                    )
                }
            }
        ),

        // Spiked Ground
        // “Whenever an opponent casts a non-Ward Spell, that player takes 1 aether damage.”
        "ESP": CardEffectDefinition(
            registerMonitors: { slot, engine in
                engine.monitors.addPlayCardMonitor(from: slot, step: .afterPlay) { context, board in
                    let current = board.slot(for: slot.owner, zone: slot.zone)
                    guard current.card == slot.card else { return }

                    let owner = slot.owner
                    let caster = context.slot.owner
                    guard caster == Self.otherSide(side: owner) else { return }

                    guard let played = PresentedCardModel.cardByCode[context.card],
                          Self.isSpell(played.type),
                          played.type != .ward
                    else { return }

                    engine.dealDamage(
                        sourceOwner: owner,
                        sourceZone: slot.zone,
                        target: caster,
                        amount: 1
                    )
                }
            }
        ),

        // Crashing Shores – only the “on fade/break” part here.
        "WCR": CardEffectDefinition(
            registerMonitors: { slot, engine in
                engine.monitors.addDiscardFromFieldMonitor(from: slot, step: .afterDiscardFromField) { context, board in
                    guard context.card.owner == slot.owner,
                          context.card.zone == slot.zone,
                          context.card.card == slot.card else { return }

                    let wave = context.card.counters[.wave] ?? 0
                    guard wave > 0 else { return }

                    let owner = slot.owner
                    let opp = Self.otherSide(side: owner)

                    engine.dealDamage(
                        sourceOwner: owner,
                        sourceZone: slot.zone,
                        target: opp,
                        amount: 2 * wave
                    )
                }

                // MARK: TODO: The “you may skip your attack phase; if you do, put a wave counter on this”
                // portion wants an explicit hook at the “do you attack?” decision point.
            }
        ),

        // Hydro Vortex
        // “The cursed opponent cannot play items for the duration of this spell.”
        "WHY": CardEffectDefinition(
            registerMonitors: { slot, engine in
                let cursed = Self.otherSide(side: slot.owner)

                engine.monitors.addPlayCardMonitor(from: slot, step: .beforePlay) { context, board in
                    let current = board.slot(for: slot.owner, zone: slot.zone)
                    guard current.card == slot.card else { return }

                    guard context.slot.owner == cursed,
                          let played = PresentedCardModel.cardByCode[context.card],
                          Self.isItem(played.type)
                    else { return }

                    context.cancelled = true
                }
            }
        ),

        // Flaming Vortex
        // “Whenever the cursed opponent plays a defense spell, they take 1 aether damage.”
        "FFL": CardEffectDefinition(
            registerMonitors: { slot, engine in
                let cursed = Self.otherSide(side: slot.owner)

                engine.monitors.addPlayCardMonitor(from: slot, step: .afterPlay) { context, board in
                    let current = board.slot(for: slot.owner, zone: slot.zone)
                    guard current.card == slot.card else { return }

                    guard context.slot.owner == cursed,
                          let played = PresentedCardModel.cardByCode[context.card],
                          (played.type == .ward || played.type == .counterspell)
                    else { return }

                    engine.dealDamage(
                        sourceOwner: slot.owner,
                        sourceZone: slot.zone,
                        target: cursed,
                        amount: 1
                    )
                }
            }
        ),

        // Countervailing Winds – permanent Gale Force
        "AOU": CardEffectDefinition(
            registerMonitors: { slot, engine in
                engine.monitors.addLoseAetherMonitor(from: slot, step: .beforeLose) { context, board in
                    let current = board.slot(for: slot.owner, zone: slot.zone)
                    guard current.card == slot.card else { return }
                    guard context.player == slot.owner else { return }

                    guard engine.phase == .defend, board.previousPlayerIsAttacking else { return }

                    let dmg = context.amount
                    guard dmg > 0 else { return }

                    context.cancelled = true

                    let attacker = Self.otherSide(side: slot.owner)
                    engine.dealDamage(
                        sourceOwner: context.source.owner,
                        sourceZone: context.source.zone,
                        target: attacker,
                        amount: dmg
                    )
                }
            }
        ),

        // Lightning Vortex
        // “Whenever a jinx deals damage to you, the attacking player takes N damage, where N is
        //  5 minus the amount of age counters on this ward.”
        "ALI": CardEffectDefinition(
            registerMonitors: { slot, engine in
                engine.monitors.addLoseAetherMonitor(from: slot, step: .afterLose) { context, board in
                    let current = board.slot(for: slot.owner, zone: slot.zone)
                    guard current.card == slot.card else { return }
                    guard context.player == slot.owner else { return }

                    guard let srcCard = PresentedCardModel.cardByCode[context.source.card],
                          srcCard.type == .jinx,
                          context.amount > 0
                    else { return }

                    let age = current.owner == .player ? engine.board.playerWardTimeCounters! : engine.board.opponentWardTimeCounters!
                    let retaliation = max(0, 5 - age)
                    guard retaliation > 0 else { return }

                    let attacker = context.source.owner
                    engine.dealDamage(
                        sourceOwner: slot.owner,
                        sourceZone: slot.zone,
                        target: attacker,
                        amount: retaliation
                    )
                }
            }
        ),

        // MARK: - Global wipes

        // Rocks Fall, Everyone Dies
        // “Break all items each opponent controls.”
        "EEV": CardEffectDefinition(
            onPlay: { slot, engine in
                let owner = slot.owner
                let opp = Self.otherSide(side: owner)

                let oppRelic = engine.board.slot(for: opp, zone: .relic)
                if !oppRelic.card.isEmpty {
                    engine.breakCard(sourceOwner: owner, zone: slot.zone, target: oppRelic)
                }

                let oppPotion = engine.board.slot(for: opp, zone: .potion)
                if !oppPotion.card.isEmpty {
                    engine.breakCard(sourceOwner: owner, zone: slot.zone, target: oppPotion)
                }
            }
        ),

        // Earthquake
        // “Break all Curses, Wards, and Relics defending opponent controls.”
        "EAR": CardEffectDefinition(
            onPlay: { slot, engine in
                let owner = slot.owner
                let defender = Self.otherSide(side: owner)

                for zone in [CardZone.curse, .ward, .relic] {
                    let target = engine.board.slot(for: defender, zone: zone)
                    if !target.card.isEmpty {
                        engine.breakCard(sourceOwner: owner, zone: slot.zone, target: target)
                    }
                }
            }
        ),

        // Icicle Javelin
        // “If defending opponent has a ward, break it. Otherwise, they lose 3 aether.”
        "WCI": CardEffectDefinition(
            onPlay: { slot, engine in
                let owner = slot.owner
                let defender = Self.otherSide(side: owner)

                let ward = engine.board.slot(for: defender, zone: .ward)
                if !ward.card.isEmpty {
                    engine.breakCard(sourceOwner: owner, zone: slot.zone, target: ward)
                } else {
                    engine.dealDamage(
                        sourceOwner: owner,
                        sourceZone: slot.zone,
                        target: defender,
                        amount: 3
                    )
                }
            }
        ),

        // Stone Rain
        // “Deal 2 aether damage to each opponent. Each opponent damaged chooses one item they have.
        //  Break it.”
        "ETO": CardEffectDefinition(
            onPlay: { slot, engine in
                let owner = slot.owner
                let opp = Self.otherSide(side: owner)

                engine.dealDamage(
                    sourceOwner: owner,
                    sourceZone: slot.zone,
                    target: opp,
                    amount: 2
                )

                // MARK: TODO: let each damaged opponent choose an item (relic/potion) to break.
                // Needs UI-driven targeting.
            }
        ),

        // Aquaball – pure jinx with strength; no extra rules needed.
        "WAQ": CardEffectDefinition(),

        // Wall of Rocks / Water Wonder Wall – purely static ward stats
        "EAL": CardEffectDefinition(),
        "WAT": CardEffectDefinition()
    ]
}


