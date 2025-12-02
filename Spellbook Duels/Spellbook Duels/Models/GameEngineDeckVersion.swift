//
//  GameEngineDeckVersion.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 11/6/25.
//

import SwiftUI
import Combine

struct GameEngineDeckVersion : Codable {
    let name: String
    let cardCodeList: [String]
    
    
    static func storedDeckToGameDeck(deck : DeckListModel) -> GameEngineDeckVersion {
        var cardcodelist: [String] = []
        var cardCount: Int = 0
        for cardCode in deck.cardList {
            cardCount = deck.cardCounts[cardCode]!
            for _ in 1...cardCount {
                cardcodelist.append(cardCode)
            }
        }
        return GameEngineDeckVersion(name: deck.deckName, cardCodeList: cardcodelist)
    }
}



