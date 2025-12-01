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
            if activateScryingWater {
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
            selectCards(cards: gameEngine.board.playerDeck, n: 4)
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

func selectCards(cards: [String], n: Int) -> some View {
    @State var selected = Set<Int>()
    
    return List {
        ForEach(0..<min(n, cards.count), id: \.self) { index in
            if let card = PresentedCardModel.cardByCode[cards[index]] {
                HStack {
                    Text(card.name)
                        Spacer()
                    if selected.contains(index) {
                            Image(systemName: "checkmark")
                        }
                    }
                    .contentShape(Rectangle()) // makes whole row tappable
                    .onTapGesture {
                        if selected.contains(index) {
                            selected.remove(index)
                        } else {
                            selected.insert(index)
                        }
                    }
            }
        }
    }
    
}

#Preview {
    PlayerDeckView(activateScryingWater: true, activateSeersScryingBowl: true)
        .environmentObject(GameEngine())
}
