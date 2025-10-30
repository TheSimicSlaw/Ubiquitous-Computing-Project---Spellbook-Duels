//
//  DecksMenuView.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 10/3/25.
//

import SwiftUI
import SwiftData

struct DecksMenuView: View {
    @Query var decks: [DeckListModel]
    
    @State private var selectedDeck: DeckListModel?
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("MenuBackgroundColor").ignoresSafeArea()
                
                VStack {
                    ZStack {
                        Rectangle()
                            .fill(Color("AccentTwo"))
                            .frame(width: .infinity, height: 190)
                            .ignoresSafeArea()
                        
                        Text("Decks")
                            .font(.custom( "InknutAntiqua-Regular", size: 50.0))
                            .bold()
                            .padding(.bottom, 50)
                        
                    }
                    
                    Spacer()
                    
                    
                    ScrollView {
                        LazyVGrid (columns: columns) {
                            ForEach(decks) { deck in
                                NavigationLink(value: deck){
                                    ZStack {
                                        VStack{
                                            Spacer(minLength: 20)
                                            
                                            DeckGridIconView(colors: [ElementColorDict.elementColors[deck.deckElements[0]]!, ElementColorDict.elementColors[deck.deckElements[1]]!])
                                            
                                            Text(deck.deckName)
                                                .font(.custom( "InknutAntiqua-Regular", size: 19.0))
                                                .foregroundStyle(.black)
                                                .lineLimit(nil)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .padding(10)
                                        }
                                        .frame(width: 200, height: .infinity)
                                        .background(Color("AccentOne"))
                                        .padding(.vertical, 0.5)
                                    }
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
    DecksMenuView()
        .modelContainer(DeckListModel.precons)
}
