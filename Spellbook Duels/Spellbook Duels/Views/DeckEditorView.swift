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
        PresentedCardModel.fullCardList
            .filter { deck.deckElements.contains($0.element) }
            .sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
    }
    var sortedCards: [(card: PresentedCardModel, count: Int)] {
        deck.cardList.compactMap { code in
            guard let card = PresentedCardModel.cardByCode[code] else {
                return nil
            }
            return (card, deck.cardCounts[code] ?? 0)
        }
        .sorted { $0.card.name.localizedCompare($1.card.name) == .orderedAscending }
    }
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ZStack {
            Color("MenuBackgroundColor").ignoresSafeArea()
            
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color("AccentTwo"))
                        .frame(width: 425, height: 190)
                        .ignoresSafeArea(edges: .top)
                        
                    Text(deck.deckName)
                        .font(.custom( "InknutAntiqua-Regular", size: 45.0))
                        .bold()
                        .padding(.bottom, 50)
                        
                }
                    
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(sortedCards, id: \.card.cardCode) { entry in
                            VStack {
                                Image(uiImage: entry.card.image!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 200)
                                    .shadow(radius: 4)
                                
                                HStack {
                                    Button {
                                        decreaseCardCount(card: entry.card)
                                    } label: {
                                        Image(systemName: "minus.rectangle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 35, height: 50)
                                            .foregroundStyle(.red)
                                            .brightness(deck.cardCounts[entry.card.cardCode] ?? 1 > 0 ? 0.0 : -0.3)
                                    }
                                    
                                    ZStack {
                                        Rectangle()
                                            .frame(width: 35, height: 26)
                                        Text("\(deck.cardCounts[entry.card.cardCode] ?? 0)")
                                            .foregroundStyle(Color.white)
                                    }
                                    
                                    Button {
                                        increaseCardCount(card: entry.card)
                                    } label: {
                                        Image(systemName: "plus.rectangle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 35, height: 50)
                                            .foregroundStyle(.green)
                                            .brightness(deck.cardCounts[entry.card.cardCode] ?? 1 < 4 ? 0.0 : -0.4)
                                    } 
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 170)
                .padding(.bottom, 50)
                    
                    
                ScrollView {
                    LazyVGrid (columns: columns) {
                        ForEach(availableCards) { card in
                            ZStack {
                                VStack{
                                    Button {
                                        increaseCardCount(card: card)
                                    } label: {
                                        Image(uiImage: card.image!)
                                            .resizable()
                                            .scaledToFit()
                                            .padding(.top)
                                    }
                                            
                                    Text(card.name)
                                        .font(.custom( "InknutAntiqua-Regular", size: 15.0))
                                            //.font(.title3)
                                        .foregroundStyle(.black)
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .padding(5)
                                }
                                .frame(width: 200, height: 300)
                                .background(Color("AccentOne"))
                                .padding(.vertical, 0.5)
                            }
                        }
                    }
                }
                .padding(.horizontal, 5)
            }
        }
    }
    
    
    func increaseCardCount(card: PresentedCardModel) {
        if deck.cardCounts[card.cardCode] == nil {
            deck.cardCounts[card.cardCode] = 1
            deck.cardList.append(card.cardCode)
        } else if deck.cardCounts[card.cardCode]! < 4 {
            deck.cardCounts[card.cardCode] = deck.cardCounts[card.cardCode]! + 1
        }
    }
    
    func decreaseCardCount(card: PresentedCardModel) {
        if deck.cardCounts[card.cardCode]! > 0 {
            deck.cardCounts[card.cardCode] = deck.cardCounts[card.cardCode]! - 1
        }
        if deck.cardCounts[card.cardCode]! == 0 {
            deck.cardList.removeAll(where: { $0 == card.cardCode })
            deck.cardCounts[card.cardCode] = nil
        }
    }
}

#Preview {
    DeckEditorView(deck: DeckListModel.counterburnPrecon)
        .modelContainer(DeckListModel.precons)
}
