//
//  BoardModel.swift
//  Spellbook Duels
//
//  Created by Rocky Williams on 11/25/25.
//

import Foundation

struct BoardModel {
    
    // MARK: Player Board State
    
    var playerAetherTotal: Int = 18
    var opponentAetherTotal: Int = 18
    
    var phase: Phase = .defend
    var activePlayer: PlayerSide = .player
    var nonActivePlayer: PlayerSide { activePlayer == .player ? .opponent : .player }
    var previousPlayerIsAttacking: Bool = false
    
    var playerCurse: CardSlot = CardSlot(owner: .player, zone: .curse, card: "ESP")
    var playerSnap: CardSlot = CardSlot(owner: .player, zone: .snap, card: "EIN")
    var playerWard: CardSlot = CardSlot(owner: .player, zone: .ward, card: "WET")
    var playerCharm: CardSlot = CardSlot(owner: .player, zone: .charm, card: "EAS")
    var playerRelic: CardSlot = CardSlot(owner: .player, zone: .relic, card: "EST")
    var playerPotion: CardSlot = CardSlot(owner: .player, zone: .potion, card: "WIN")
    var playerCurseTimeCounters: Int? = nil
    var playerWardTimeCounters: Int? = nil
    var playerCharmTimeCounters: Int? = nil
    var playerPotionBrewCounters: Int? = nil
    var playerPotionBrewed: Bool {
        if let ppbcNum = playerPotionBrewCounters, let potion = PresentedCardModel.cardByCode[playerPotion.card] {
            return ppbcNum >= potion.costVal
        } else {
            return false
        }
    }
    
    var playerDeck: [String] = PresentedCardModel.fullCardList.map{ $0.cardCode }.shuffled()
    var playerHand: [String] = ["EAS", "EST", "WIN", "WAS", "EAL"]
    var playerDiscard: [String] = []
    
    // MARK: Opponent Board State
    
    var opponentCurse: CardSlot = CardSlot(owner: .opponent, zone: .curse, card: "")
    var opponentSnap: CardSlot = CardSlot(owner: .opponent, zone: .snap, card: "")
    var opponentWard: CardSlot = CardSlot(owner: .opponent, zone: .ward, card: "")
    var opponentCharm: CardSlot = CardSlot(owner: .opponent, zone: .charm, card: "")
    var opponentRelic: CardSlot = CardSlot(owner: .opponent, zone: .relic, card: "")
    var opponentPotion: CardSlot = CardSlot(owner: .opponent, zone: .potion, card: "")
    var opponentCurseTimeCounters: Int? = nil
    var opponentWardTimeCounters: Int? = nil
    var opponentCharmTimeCounters: Int? = nil
    var opponentPotionBrewCounters: Int? = nil
    var opponentPotionBrewed: Bool {
        if let ppbcNum = opponentPotionBrewCounters, let potion = PresentedCardModel.cardByCode[opponentPotion.card] {
            return ppbcNum >= potion.costVal
        } else {
            return false
        }
    }
    
    var opponentHand: [String] = []
    var opponentDeck: [String] = []
    var opponentDiscard: [String] = []
    // MARK: Setters
    
    mutating func setPlayer(curse: CardSlot, snap: CardSlot, ward: CardSlot, charm: CardSlot, relic: CardSlot, potion: CardSlot) {
        self.playerCurse = curse
        self.playerSnap = snap
        self.playerWard = ward
        self.playerCharm = charm
        self.playerRelic = relic
        self.playerPotion = potion
    }
    
    mutating func setOpponent(curse: CardSlot, snap: CardSlot, ward: CardSlot, charm: CardSlot, relic: CardSlot, potion: CardSlot) {
        self.opponentCurse = curse
        self.opponentSnap = snap
        self.opponentWard = ward
        self.opponentCharm = charm
        self.opponentRelic = relic
        self.opponentPotion = potion
    }
    
    mutating func setSlot(_ slot: CardSlot) {
        switch (slot.owner, slot.zone) {
            case (.player, .curse):  playerCurse  = slot
            case (.player, .snap):   playerSnap   = slot
            case (.player, .ward):   playerWard   = slot
            case (.player, .charm):  playerCharm  = slot
            case (.player, .relic):  playerRelic  = slot
            case (.player, .potion): playerPotion = slot

            case (.opponent, .curse):  opponentCurse  = slot
            case (.opponent, .snap):   opponentSnap   = slot
            case (.opponent, .ward):   opponentWard   = slot
            case (.opponent, .charm):  opponentCharm  = slot
            case (.opponent, .relic):  opponentRelic  = slot
            case (.opponent, .potion): opponentPotion = slot
        }
    }
    
    mutating func setHand(_ hand: [String], owner: PlayerSide) {
        if owner == .player {
            playerHand = hand
        } else {
            opponentHand = hand
        }
    }
    
    // MARK: - Getters
    
    func getSlot(_ owner: PlayerSide, _ zone: CardZone) -> CardSlot {
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
    
    func getHand(owner: PlayerSide) -> [String] {
        if owner == .player { return playerHand } else { return opponentHand }
    }
    
//    func toDictionary() throws -> [String: Any] {
//        let data = try JSONEncoder().encode(self)
//        let jsonObject = try JSONSerialization.jsonObject(with: data)
//        return jsonObject as? [String: Any] ?? [:]
//    }
    
    func boardToDictionary() -> [String: Any] {
        let boardDictionary: [String: Any] = [
            "aetherTotal": self.playerAetherTotal,
            "deck": self.playerDeck,
            "hand": self.playerHand,
            "discard": self.playerHand,
            "phase": self.phase.rawValue,
            "curse": self.playerCurse.card,
            "snap": self.playerSnap.card,
            "ward": self.playerWard.card,
            "charm": self.playerCharm.card,
            "relic": self.playerRelic.card,
            "potion": self.playerPotion,
            "curseCounter": self.playerCurseTimeCounters ?? 0,
            "wardCounter": self.playerWardTimeCounters ?? 0,
            "charmCounter": self.playerCharmTimeCounters ?? 0,
            "potionCounter": self.playerPotionBrewCounters ?? 0,
        ]
        return boardDictionary
    }
    
    mutating func dictionaryToBoard(_ dict: [String: Any]) {
        opponentAetherTotal = dict["aetherTotal"] as? Int ?? 18
        opponentDiscard = dict["discard"] as? [String] ?? []
        let raw = dict["phase"] as? Int ?? 0
        phase = Phase(rawValue: raw) ?? .defend
        opponentCurse.card = dict["curse"] as? String ?? ""
        opponentSnap.card = dict["snap"] as? String ?? ""
        opponentWard.card = dict["ward"] as? String ?? ""
        opponentCharm.card = dict["charm"] as? String ?? ""
        opponentRelic.card = dict["relic"] as? String ?? ""
        opponentPotion.card = dict["potion"] as? String ?? ""
        opponentCurseTimeCounters = dict["curseCounter"] as? Int ?? 0
        opponentWardTimeCounters = dict["wardCounter"] as? Int ?? 0
        opponentCharmTimeCounters = dict["charmCounter"] as? Int ?? 0
        opponentPotionBrewCounters = dict["potionCounter"] as? Int ?? 0
    }
    
}

enum PlayerSide: Codable {
    case player, opponent
}

enum CardZone: Hashable, Codable {
    case curse, snap, ward, charm, relic, potion
    
    static func zoneForCard(_ type: CardType) -> CardZone {
        switch type {
        case .curse: return .curse
        case .ward: return .ward
        case .relic: return .relic
        case .charm: return .charm
        case .potion: return .potion
        default: return .snap
        }
    }
}

enum Counter: String, Hashable, Codable {
    case wave
    case stone
}

struct CardSlot: Hashable, Codable {
    var owner: PlayerSide
    var zone: CardZone
    var card: String
    var counters: [Counter: Int]
    var isHighlighted: Bool = false
    
    init(owner: PlayerSide, zone: CardZone, card: String = "", counters: [Counter: Int] = [:]) {
        self.owner = owner
        self.zone = zone
        self.card = card
        self.counters = counters
    }
}
