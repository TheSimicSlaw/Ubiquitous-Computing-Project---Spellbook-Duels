//
//  BoardModel.swift
//  Spellbook Duels
//
//  Created by Rocky Williams on 11/25/25.
//

struct BoardModel: Codable {
    var playerAetherTotal: Int = 18
    var opponentAetherTotal: Int = 18
    
    var playerCurse: String = ""
    var playerSnap: String = ""
    var playerWard: String = ""
    var playerCharm: String = ""
    var playerRelic: String = ""
    var playerPotion: String = ""
    var playerCurseTimeCounters: Int? = nil
    var playerWardTimeCounters: Int? = nil
    var playerCharmTimeCounters: Int? = nil
    var playerPotionBrewCounters: Int? = nil
    var playerPotionBrewed: Bool {
        if let ppbcNum = playerPotionBrewCounters, let potion = PresentedCardModel.cardByCode[playerPotion] {
            return ppbcNum >= potion.costVal
        } else {
            return false
        }
    }
    
    var opponentCurse: String = ""
    var opponentSnap: String = ""
    var opponentWard: String = ""
    var opponentCharm: String = ""
    var opponentRelic: String = ""
    var opponentPotion: String = ""
    var opponentCurseTimeCounters: Int? = nil
    var opponentWardTimeCounters: Int? = nil
    var opponentCharmTimeCounters: Int? = nil
    var opponentPotionBrewCounters: Int? = nil
    var opponentPotionBrewed: Bool {
        if let ppbcNum = opponentPotionBrewCounters, let potion = PresentedCardModel.cardByCode[opponentPotion] {
            return ppbcNum >= potion.costVal
        } else {
            return false
        }
    }
    
    var playerDeck: [String] = []
    var playerHand: [String] = []
    var playerDiscard: [String] = []
    
    var opponentHand: [String] = []
    var opponentDiscard: [String] = []
    
}

