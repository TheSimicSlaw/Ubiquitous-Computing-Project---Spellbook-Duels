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
    
}

