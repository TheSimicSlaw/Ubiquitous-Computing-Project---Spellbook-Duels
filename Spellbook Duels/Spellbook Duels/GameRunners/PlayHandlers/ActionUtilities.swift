//
//  ActionUtilities.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 11/25/25.
//

import SwiftUI

// MARK: - Action steps

enum DealDamageStep: Int, Codable {
    case beforeDamage = 0
    case afterDamage  = 1
}

enum GainAetherStep: Int, Codable {
    case beforeGain = 0
    case afterGain  = 1
}

enum LoseAetherStep: Int, Codable {
    case beforeLose = 0
    case afterLose  = 1
}

enum BreakCardStep: Int, Codable {
    case beforeBreak = 0
    case afterBreak  = 1
}

enum DiscardFromFieldStep: Int, Codable {
    case beforeDiscardFromField = 0
    case afterDiscardFromField  = 1
}

enum PullToHandStep: Int, Codable {
    case beforePullToHand = 0
    case afterPullToHand = 1
}

enum PlayCardStep: Int, Codable {
    case beforePlay = 0
    case afterPlay  = 1
}

// MARK: - Contexts passed through monitors

struct DealDamageContext {
    var source: CardSlot
    var target: PlayerSide
    var amount: Int
    var cancelled: Bool = false
}

struct LoseAetherContext {
    var source: CardSlot
    var player: PlayerSide
    var amount: Int
    var cancelled: Bool = false
}

struct GainAetherContext {
    var player: PlayerSide
    var amount: Int
    var cancelled: Bool = false
}

struct BreakCardContext {
    var source: CardSlot
    var target: CardSlot
    var cancelled: Bool = false
}

struct DiscardFromFieldContext {
    var card: CardSlot
    var cardOwner: PlayerSide
}

struct PullToHandContext {
    var card: CardSlot
    var cardOwner: PlayerSide
}

struct PlayCardFieldContext {
    var slot: CardSlot
    var card: String
    var cancelled: Bool = false
}

// MARK: - Monitor closure types

typealias DealDamageMonitor = (_ context: inout DealDamageContext, _ board: inout BoardModel) -> Void
typealias LoseAetherMonitor = (_ context: inout LoseAetherContext,  _ board: inout BoardModel) -> Void
typealias GainAetherMonitor = (_ context: inout GainAetherContext,  _ board: inout BoardModel) -> Void
typealias BreakCardMonitor = (_ context: inout BreakCardContext,   _ board: inout BoardModel) -> Void
typealias DiscardFromFieldMonitor = (_ context: inout DiscardFromFieldContext,   _ board: inout BoardModel) -> Void
typealias PullToHandMonitor = (_ context: inout PullToHandContext,   _ board: inout BoardModel) -> Void
typealias PlayCardMonitor = (_ context: inout PlayCardFieldContext,   _ board: inout BoardModel) -> Void

// MARK: - Per-store monitor entries

struct DealDamageMonitorEntry {
    let id: UUID
    let position: CardSlot
    let step: DealDamageStep
    let handler: DealDamageMonitor
}

struct LoseAetherMonitorEntry {
    let id: UUID
    let position: CardSlot
    let step: LoseAetherStep
    let handler: LoseAetherMonitor
}

struct GainAetherMonitorEntry {
    let id: UUID
    let position: CardSlot
    let step: GainAetherStep
    let handler: GainAetherMonitor
}

struct BreakCardMonitorEntry {
    let id: UUID
    let position: CardSlot
    let step: BreakCardStep
    let handler: BreakCardMonitor
}

struct DiscardFromFieldMonitorEntry {
    let id: UUID
    let position: CardSlot
    let step: DiscardFromFieldStep
    let handler: DiscardFromFieldMonitor
}

struct PullToHandMonitorEntry {
    let id: UUID
    let position: CardSlot
    let step: PullToHandStep
    let handler: PullToHandMonitor
}

struct PlayCardMonitorEntry {
    let id: UUID
    let position: CardSlot
    let step: PlayCardStep
    let handler: PlayCardMonitor
}

// MARK: - Per-type monitor stores

struct DealDamageMonitorStore {
    private(set) var entries: [DealDamageMonitorEntry] = []

    @discardableResult
    mutating func add(at position: CardSlot, step: DealDamageStep, _ monitor: @escaping DealDamageMonitor) -> UUID {
        let id = UUID()
        entries.append(
            DealDamageMonitorEntry(id: id, position: position, step: step, handler: monitor)
        )
        return id
    }

    mutating func remove(_ id: UUID) {
        entries.removeAll { $0.id == id }
    }

    mutating func removeAll(at position: CardSlot) {
        entries.removeAll { $0.position == position }
    }
}

struct LoseAetherMonitorStore {
    private(set) var entries: [LoseAetherMonitorEntry] = []

    @discardableResult
    mutating func add(at position: CardSlot, step: LoseAetherStep, _ monitor: @escaping LoseAetherMonitor) -> UUID {
        let id = UUID()
        entries.append(
            LoseAetherMonitorEntry(id: id, position: position, step: step, handler: monitor)
        )
        return id
    }

    mutating func remove(_ id: UUID) {
        entries.removeAll { $0.id == id }
    }

    mutating func removeAll(at position: CardSlot) {
        entries.removeAll { $0.position == position }
    }
}

struct GainAetherMonitorStore {
    private(set) var entries: [GainAetherMonitorEntry] = []

    @discardableResult
    mutating func add(at position: CardSlot, step: GainAetherStep, _ monitor: @escaping GainAetherMonitor) -> UUID {
        let id = UUID()
        entries.append(
            GainAetherMonitorEntry(id: id, position: position, step: step, handler: monitor)
        )
        return id
    }

    mutating func remove(_ id: UUID) {
        entries.removeAll { $0.id == id }
    }

    mutating func removeAll(at position: CardSlot) {
        entries.removeAll { $0.position == position }
    }
}

struct BreakCardMonitorStore {
    private(set) var entries: [BreakCardMonitorEntry] = []

    @discardableResult
    mutating func add(at position: CardSlot, step: BreakCardStep, _ monitor: @escaping BreakCardMonitor) -> UUID {
        let id = UUID()
        entries.append(
            BreakCardMonitorEntry(id: id, position: position, step: step, handler: monitor)
        )
        return id
    }

    mutating func remove(_ id: UUID) {
        entries.removeAll { $0.id == id }
    }

    mutating func removeAll(at position: CardSlot) {
        entries.removeAll { $0.position == position }
    }
}

struct DiscardFromFieldMonitorStore {
    private(set) var entries: [DiscardFromFieldMonitorEntry] = []

    @discardableResult
    mutating func add(at position: CardSlot, step: DiscardFromFieldStep, _ monitor: @escaping DiscardFromFieldMonitor) -> UUID {
        let id = UUID()
        entries.append(
            DiscardFromFieldMonitorEntry(id: id, position: position, step: step, handler: monitor)
        )
        return id
    }

    mutating func remove(_ id: UUID) {
        entries.removeAll { $0.id == id }
    }

    mutating func removeAll(at position: CardSlot) {
        entries.removeAll { $0.position == position }
    }
}

struct PullToHandMonitorStore {
    private(set) var entries: [PullToHandMonitorEntry] = []

    @discardableResult
    mutating func add(at position: CardSlot, step: PullToHandStep, _ monitor: @escaping PullToHandMonitor) -> UUID {
        let id = UUID()
        entries.append(
            PullToHandMonitorEntry(id: id, position: position, step: step, handler: monitor)
        )
        return id
    }

    mutating func remove(_ id: UUID) {
        entries.removeAll { $0.id == id }
    }

    mutating func removeAll(at position: CardSlot) {
        entries.removeAll { $0.position == position }
    }
}

struct PlayCardMonitorStore {
    private(set) var entries: [PlayCardMonitorEntry] = []

    @discardableResult
    mutating func add(at position: CardSlot, step: PlayCardStep, _ monitor: @escaping PlayCardMonitor) -> UUID {
        let id = UUID()
        entries.append(
            PlayCardMonitorEntry(id: id, position: position, step: step, handler: monitor)
        )
        return id
    }

    mutating func remove(_ id: UUID) {
        entries.removeAll { $0.id == id }
    }

    mutating func removeAll(at position: CardSlot) {
        entries.removeAll { $0.position == position }
    }
}

// MARK: - Complete Monitor Store/Registry

enum MonitorKind: Codable {
    case dealDamage
    case loseAether
    case gainAether
    case breakCard
    case discardFromField
    case pullToHand
    case playCard
}

struct MonitorHandle: Codable, Hashable {
    let kind: MonitorKind
    let id: UUID
}

struct Monitors {
    var dealDamage = DealDamageMonitorStore()
    var loseAether = LoseAetherMonitorStore()
    var gainAether = GainAetherMonitorStore()
    var breakCard = BreakCardMonitorStore()
    var discardFromField = DiscardFromFieldMonitorStore()
    var pullToHand = PullToHandMonitorStore()
    var playCard = PlayCardMonitorStore()

    private var registry: [CardSlot: [MonitorHandle]] = [:]


    @discardableResult
    mutating func addDealDamageMonitor(from slot: CardSlot, step: DealDamageStep, _ monitor: @escaping DealDamageMonitor) -> UUID {
        let pos = slot
        let id = dealDamage.add(at: pos, step: step, monitor)
        register(handle: MonitorHandle(kind: .dealDamage, id: id), for: pos)
        return id
    }
    
    @discardableResult
    mutating func addLoseAetherMonitor(from slot: CardSlot, step: LoseAetherStep, _ monitor: @escaping LoseAetherMonitor) -> UUID {
        let pos = slot
        let id = loseAether.add(at: pos, step: step, monitor)
        register(handle: MonitorHandle(kind: .loseAether, id: id), for: pos)
        return id
    }
    
    @discardableResult
    mutating func addGainAetherMonitor(from slot: CardSlot, step: GainAetherStep, _ monitor: @escaping GainAetherMonitor) -> UUID {
        let pos = slot
        let id = gainAether.add(at: pos, step: step, monitor)
        register(handle: MonitorHandle(kind: .gainAether, id: id), for: pos)
        return id
    }
    
    @discardableResult
    mutating func addBreakCardMonitor(from slot: CardSlot, step: BreakCardStep, _ monitor: @escaping BreakCardMonitor) -> UUID {
        let pos = slot
        let id = breakCard.add(at: pos, step: step, monitor)
        register(handle: MonitorHandle(kind: .breakCard, id: id), for: pos)
        return id
    }
    
    @discardableResult
    mutating func addDiscardFromFieldMonitor(from slot: CardSlot, step: DiscardFromFieldStep, _ monitor: @escaping DiscardFromFieldMonitor) -> UUID {
        let pos = slot
        let id = discardFromField.add(at: pos, step: step, monitor)
        register(handle: MonitorHandle(kind: .discardFromField, id: id), for: pos)
        return id
    }
    
    @discardableResult
    mutating func addPullToHandMonitor(from slot: CardSlot, step: PullToHandStep, _ monitor: @escaping PullToHandMonitor) -> UUID {
        let pos = slot
        let id = pullToHand.add(at: pos, step: step, monitor)
        register(handle: MonitorHandle(kind: .pullToHand, id: id), for: pos)
        return id
    }
    
    @discardableResult
    mutating func addPlayCardMonitor(from slot: CardSlot, step: PlayCardStep, _ monitor: @escaping PlayCardMonitor) -> UUID {
        let pos = slot
        let id = playCard.add(at: pos, step: step, monitor)
        register(handle: MonitorHandle(kind: .playCard, id: id), for: pos)
        return id
    }


    mutating func removeAllMonitors(for slot: CardSlot) {
        let pos = slot
        guard let handles = registry[pos] else { return }

        for handle in handles {
            switch handle.kind {
            case .dealDamage:
                dealDamage.remove(handle.id)
            case .loseAether:
                loseAether.remove(handle.id)
            case .gainAether:
                gainAether.remove(handle.id)
            case .breakCard:
                breakCard.remove(handle.id)
            case .discardFromField:
                discardFromField.remove(handle.id)
            case .pullToHand:
                pullToHand.remove(handle.id)
            case .playCard:
                playCard.remove(handle.id)
            }
        }

        registry[pos] = nil
    }

    private mutating func register(handle: MonitorHandle, for pos: CardSlot) {
        if registry[pos] != nil {
            registry[pos]!.append(handle)
        } else {
            registry[pos] = [handle]
        }
    }
}

// MARK: - BoardModel helper

extension BoardModel {
    func slot(for owner: PlayerSide, zone: CardZone) -> CardSlot {
        switch (owner, zone) {
        case (.player, .curse):  return playerCurse
        case (.player, .snap):   return playerSnap
        case (.player, .ward):   return playerWard
        case (.player, .charm):  return playerCharm
        case (.player, .relic):  return playerRelic
        case (.player, .potion): return playerPotion

        case (.opponent, .curse):  return opponentCurse
        case (.opponent, .snap):   return opponentSnap
        case (.opponent, .ward):   return opponentWard
        case (.opponent, .charm):  return opponentCharm
        case (.opponent, .relic):  return opponentRelic
        case (.opponent, .potion): return opponentPotion
        }
    }
}

