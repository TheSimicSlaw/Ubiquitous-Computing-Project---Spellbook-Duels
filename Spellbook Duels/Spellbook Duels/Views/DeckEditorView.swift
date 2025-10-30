//
//  DeckEditorView.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 10/3/25.
//

import SwiftUI
import SwiftData

struct DeckEditorView: View {
    
    var deck: DeckListModel
    var availableCards: [PresentedCardModel] {
        PresentedCardModel.fullCardList.filter { deck.deckElements.contains($0.element)}
    }
    
    var body: some View {
        Text("Deck Editor View")
    }
}

#Preview {
    //DeckEditorView()
}
