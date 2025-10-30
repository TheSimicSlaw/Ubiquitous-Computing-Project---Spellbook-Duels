//
//  DeckEditorView.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 10/3/25.
//

import SwiftUI
import SwiftData
import UIKit

struct DeckEditorView: View {
    
    var deck: DeckListModel
    var availableCards: [PresentedCardModel] {
        PresentedCardModel.fullCardList.filter { deck.deckElements.contains($0.element)}
    }
    var sortedCards: [(card: PresentedCardModel, count: Int)] {
        deck.cardList.compactMap { code in
            guard let card = PresentedCardModel.cardByCode[code] else { return nil }
            return (card, deck.cardCounts[code] ?? 0)
        }
        .sorted { $0.card.name.localizedCompare($1.card.name) == .orderedAscending }
    }
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("MenuBackgroundColor").ignoresSafeArea()
                
                VStack {
                    ZStack {
                        Rectangle()
                            .fill(Color("AccentTwo"))
                            .frame(width: 425, height: 190)
                            .ignoresSafeArea()
                        
                        Text(deck.deckName)
                            .font(.custom( "InknutAntiqua-Regular", size: 50.0))
                            .bold()
                            .padding(.bottom, 50)
                        
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(sortedCards, id: \.card.cardCode) { entry in
                                Image(uiImage: entry.card.image!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 200)
                                    .padding(.bottom, 5)
                                    .shadow(radius: 4)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 170)
                    .padding(.bottom, 20)
                    
                    
                    ScrollView {
                        LazyVGrid (columns: columns) {
                            ForEach(availableCards) { card in
                                ZStack {
                                    VStack{
                                        Image(uiImage: card.image!)
                                            .resizable()
                                            .scaledToFit()
                                            
                                        Text(card.name)
                                            .font(.custom( "InknutAntiqua-Regular", size: 15.0))
                                            //.font(.title3)
                                            .foregroundStyle(.black)
                                            .lineLimit(nil)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .padding(10)
                                    }
                                    .frame(width: 200, height: 300)
                                    .background(Color("AccentOne"))
                                    .padding(.vertical, 0.5)
                                }
                            }
                        }
                    }
                }
                .navigationDestination(for: DeckListModel.self, destination: DeckEditorView.init)
            }
        }
    }
}

#Preview {
    DeckEditorView(deck: DeckListModel.counterburnPrecon)
        .modelContainer(DeckListModel.precons)
}
