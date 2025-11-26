//
//  BoardModel.swift
//  Spellbook Duels
//
//  Created by Rocky Williams on 11/25/25.
//

struct BoardModel {
    var playerAetherTotal: Int = 18
    var opponentAetherTotal: Int = 18
    
    var playerCurse: String = ""
    var playerSnap: String = ""
    var playerWard: String = ""
    var playerCharm: String = ""
    var playerRelic: String = ""
    var playerPotion: String = ""
    
    var opponentCurse: String = ""
    var opponentSnap: String = ""
    var opponentWard: String = ""
    var opponentCharm: String = ""
    var opponentRelic: String = ""
    var opponentPotion: String = ""
    
    var playerDeck: [String] = []
    var playerHand: [String] = []
    var playerDiscard: [String] = []
    
    var opponentHand: [String] = []
    var opponentDiscard: [String] = []
    
    // the following two functions are for test purposes
    mutating func setPlayer(curse: String, snap: String, ward: String, charm: String, relic: String, potion: String) {
        self.playerCurse = curse
        self.playerSnap = snap
        self.playerWard = ward
        self.playerCharm = charm
        self.playerRelic = relic
        self.playerPotion = potion
    }
    
    mutating func setOpponent(curse: String, snap: String, ward: String, charm: String, relic: String, potion: String) {
        self.opponentCurse = curse
        self.opponentSnap = snap
        self.opponentWard = ward
        self.opponentCharm = charm
        self.opponentRelic = relic
        self.opponentPotion = potion
    }
}


