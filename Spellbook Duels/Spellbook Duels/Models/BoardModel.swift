//
//  BoardModel.swift
//  Spellbook Duels
//
//  Created by Rocky Williams on 11/25/25.
//

struct BoardModel: Codable {
    
    // MARK: Player Board State
    
    var playerAetherTotal: Int = 18
    var opponentAetherTotal: Int = 18
    
    var playerCurse: CardSlot = CardSlot(owner: .player, zone: .curse, card: "")
    var playerSnap: CardSlot = CardSlot(owner: .player, zone: .snap, card: "")
    var playerWard: CardSlot = CardSlot(owner: .player, zone: .ward, card: "")
    var playerCharm: CardSlot = CardSlot(owner: .player, zone: .charm, card: "")
    var playerRelic: CardSlot = CardSlot(owner: .player, zone: .relic, card: "")
    var playerPotion: CardSlot = CardSlot(owner: .player, zone: .potion, card: "")
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
    
    var playerDeck: [String] = []
    var playerHand: [String] = []
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
}

enum PlayerSide: Codable {
    case player, opponent
}

enum CardZone: Hashable, Codable {
    case curse, snap, ward, charm, relic, potion
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
    
    init(owner: PlayerSide, zone: CardZone, card: String = "", counters: [Counter: Int] = [:]) {
        self.owner = owner
        self.zone = zone
        self.card = card
        self.counters = counters
    }
}
