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
}

func storedDeckToGameDeck(deck : DeckListModel) -> GameEngineDeckVersion {
    var cardcodelist : [String] = []
    for cardCode in deck.cardList {
        var cardCount = deck.cardCounts[cardCode]!
        for count in 1...cardCount {
            cardcodelist.append(cardCode)
        }
    }
    return GameEngineDeckVersion(name: deck.deckName, cardCodeList: cardcodelist)
}


