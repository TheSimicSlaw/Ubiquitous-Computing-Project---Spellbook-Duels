//
//  ActionUtilities.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 11/25/25.
//

import SwiftUI

// MARK: - High-level game actions

//enum GameActionType: String, Codable {
//    case playCard
//    case gainAether
//    case dealDamage
//    case breakCard
//}
//
//struct GameAction: Identifiable, Codable {
//    let id: UUID
//    let type: GameActionType
//    let player: PlayerSide          // who is performing the action
//
//
//    init(
//        id: UUID = UUID(),
//        type: GameActionType,
//        player: PlayerSide,
//        cardCode: String? = nil,
//        amount: Int? = nil,
//        targetPlayer: PlayerSide? = nil,
//        targetSlot: CardSlot? = nil
//    ) {
//        self.id = id
//        self.type = type
//        self.player = player
//        self.cardCode = cardCode
//        self.amount = amount
//        self.targetPlayer = targetPlayer
//        self.targetSlot = targetSlot
//    }
//}


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

// MARK: - Contexts passed through monitors

struct DealDamageContext {
    var source: CardSlot
    var target: PlayerSide
    var amount: Int
    var cancelled: Bool = false
}

struct GainAetherContext {
    var player: PlayerSide
    var amount: Int
    var cancelled: Bool = false
}

struct BreakCardContext {
    var target: CardSlot
    var cancelled: Bool = false
}

// MARK: - Monitor closure types

typealias DealDamageMonitor = (_ ctx: inout DealDamageContext, _ board: inout BoardModel) -> Void
typealias GainAetherMonitor  = (_ ctx: inout GainAetherContext,  _ board: inout BoardModel) -> Void
typealias BreakCardMonitor   = (_ ctx: inout BreakCardContext,   _ board: inout BoardModel) -> Void

// MARK: - Per-store monitor entries

struct DealDamageMonitorEntry {
    let id: UUID
    let position: CardSlot
    let step: DealDamageStep
    let handler: DealDamageMonitor
}

struct GainAetherMonitorEntry {
    let id: UUID
    let position: CardSlot
    let handler: GainAetherMonitor
}

struct BreakCardMonitorEntry {
    let id: UUID
    let position: CardSlot
    let handler: BreakCardMonitor
}

// MARK: - Per-type monitor stores

struct DealDamageMonitorStore {
    private(set) var entries: [DealDamageMonitorEntry] = []

    @discardableResult
    mutating func add(
        at position: CardSlot,
        step: DealDamageStep,
        _ monitor: @escaping DealDamageMonitor
    ) -> UUID {
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

struct GainAetherMonitorStore {
    private(set) var entries: [GainAetherMonitorEntry] = []

    @discardableResult
    mutating func add(at position: CardSlot, _ monitor: @escaping GainAetherMonitor) -> UUID {
        let id = UUID()
        entries.append(
            GainAetherMonitorEntry(id: id, position: position, handler: monitor)
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
    mutating func add(
        at position: CardSlot,
        _ monitor: @escaping BreakCardMonitor
    ) -> UUID {
        let id = UUID()
        entries.append(
            BreakCardMonitorEntry(id: id, position: position, handler: monitor)
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
    case gainAether
    case breakCard
}

struct MonitorHandle: Codable, Hashable {
    let kind: MonitorKind
    let id: UUID
}

struct Monitors {
    var dealDamage = DealDamageMonitorStore()
    var gainAether = GainAetherMonitorStore()
    var breakCard = BreakCardMonitorStore()

    private var registry: [CardSlot: [MonitorHandle]] = [:]


    @discardableResult
    mutating func addDealDamageMonitor(from slot: CardSlot, step: DealDamageStep, _ monitor: @escaping DealDamageMonitor) -> UUID {
        let pos = slot
        let id = dealDamage.add(at: pos, step: step, monitor)
        register(handle: MonitorHandle(kind: .dealDamage, id: id), for: pos)
        return id
    }

    @discardableResult
    mutating func addGainAetherMonitor(from slot: CardSlot, step: GainAetherStep, _ monitor: @escaping GainAetherMonitor) -> UUID {
        let pos = slot
        let id = gainAether.add(at: pos, monitor)
        register(handle: MonitorHandle(kind: .gainAether, id: id), for: pos)
        return id
    }

    @discardableResult
    mutating func addBreakCardMonitor(from slot: CardSlot, _ monitor: @escaping BreakCardMonitor) -> UUID {
        let pos = slot
        let id = breakCard.add(at: pos, monitor)
        register(handle: MonitorHandle(kind: .breakCard, id: id), for: pos)
        return id
    }


    mutating func removeAllMonitors(for slot: CardSlot) {
        let pos = slot
        guard let handles = registry[pos] else { return }

        for handle in handles {
            switch handle.kind {
            case .dealDamage:
                dealDamage.remove(handle.id)
            case .gainAether:
                gainAether.remove(handle.id)
            case .breakCard:
                breakCard.remove(handle.id)
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

