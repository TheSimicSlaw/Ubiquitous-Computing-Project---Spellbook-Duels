//
//  PlayerDeckView.swift
//  Spellbook Duels
//
//  Created by Rocky Williams on 12/1/25.
//

import SwiftUI

struct PlayerDeckView: View {
    @EnvironmentObject var gameEngine: GameEngine
    @State var activateScryingWater: Bool
    @State var activateSeersScryingBowl: Bool // shortened because activateSeersScryingBowl is a long variable name
    @State private var showTopNCards = false
    @State private var selectCardsFromDeck = false
    //@State private var cardList: [String] = []
    
    var body: some View {
        Menu {
            if activateScryingWater { // temporary for testing purposes; actual activation will be handled in CardEffects
                Button("Activate Scrying Water") {
                    selectCardsFromDeck = true
                }
            }
            if activateSeersScryingBowl {
                Button("Activate Seers Scrying Bowl") {
                    showTopNCards = true
                }
            }
        } label: {
            ZStack {
                Rectangle()
                    .fill(.brown)
                    .frame(width: 50, height: 80)
                Image(systemName: "wand.and.rays")
                    .foregroundStyle(.white)
            }
        }
        .sheet(isPresented: $showTopNCards) {
            viewTopNCards(deck: gameEngine.board.playerDeck, n: 3)
        }
        .sheet(isPresented: $selectCardsFromDeck) {
            let cards: [String] = [
                gameEngine.board.playerDeck[0],
                gameEngine.board.playerDeck[1],
                gameEngine.board.playerDeck[2],
                gameEngine.board.playerDeck[3]]
            SelectCardsView(cards: cards, numCardsToSelect: 1) { cardsSelected, notSelected in
                gameEngine.addCardsToHand(cardsSelected, player: .player)
                gameEngine.cardsToDiscard(notSelected, from: &gameEngine.board.playerDeck, player: .player)
                gameEngine.board.playerDeck.remove(at: 0)
            }
        }
        
    }
}

func viewTopNCards(deck: [String], n: Int) -> some View {
    NavigationStack {
        List {
            ForEach(0..<min(n, deck.count), id: \.self) { index in
                if let card = PresentedCardModel.cardByCode[deck[index]] {
                    NavigationLink {
                        DetailedCardView(card: card)
                    } label: {
                        Text("\(card.name)")
                            .font(.custom("InknutAntiqua-Regular", size: 14))
                            
                    }
                    .listRowBackground(Color.menuBackground)
                }
            }
        }
        .scrollContentBackground(.hidden)   // remove the default white background
        .background(Color.accentOne)
    }
}

#Preview {
    PlayerDeckView(activateScryingWater: true, activateSeersScryingBowl: true)
        .environmentObject(GameEngine())
}
