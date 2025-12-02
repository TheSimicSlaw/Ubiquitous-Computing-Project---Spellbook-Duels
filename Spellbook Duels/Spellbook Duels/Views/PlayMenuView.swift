//
//  PlayMenuView.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 10/3/25.
//

import SwiftUI
import SwiftData

struct PlayMenuView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var viewController: ViewController
    @Query var decks: [DeckListModel]
    
    @State private var selectedDeck: DeckListModel? = nil
    @State private var isLoading = false
    @State private var navigating = false
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ZStack(alignment: .top) {
            Color("MenuBackgroundColor")
                .ignoresSafeArea()
            VStack {
                Text("Spellbook Duels")
                    .font(.custom("InknutAntiqua-Bold", size: 35.0))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .background(Color.accentTwo)
                NavigationStack {
                    ScrollView {
                        LazyVGrid(columns: columns) {
                            ForEach(decks) {deck in
                                if (deck.totalCards == 60 && deck.deckElements.count == 2) {
                                    VStack {
                                        Button {
                                            selectedDeck = deck
                                        } label: {
                                            VStack {
                                                DeckGridIconView(colors: [ElementColorDict.elementColors[deck.deckElements[0]]!, ElementColorDict.elementColors[deck.deckElements[1]]!])
                                                    
                                                    Text(deck.deckName)
                                                        .font(.custom( "InknutAntiqua-Regular", size: 11.0))
                                                        .foregroundStyle(.black)
                                                        .lineLimit(nil)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                        .padding(10)
                                            }
                                            
                                        }
                                        
                                    }
                                }
                            }
//                            DeckGridIconView(colors: [.blue, .red])
//                            DeckGridIconView(colors: [.blue, .brown])
//                            DeckGridIconView(colors: [.white, .red])
//                            DeckGridIconView(colors: [.brown, .red])
//                            DeckGridIconView(colors: [.blue, .white])
//                            DeckGridIconView(colors: [.white, .brown])
                        }
                        .padding(.leading, 60)
                        .padding(.trailing, 60)
                    }
                    //.border(.black)
                    if let selectedDeck {
                        Button("Start Game") {
                            startLoading()
                        }
                        .frame(width: 200, height: 50)
                        .font(.custom("InknutAntiqua-Regular", size: 20))
                        .foregroundStyle(.black)
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.accentOne)
                        }
                        .padding(.bottom, 20)
                    }
                    
                    // technically works, but uses an outdated method. Will need to change later
                    NavigationLink(destination: LobbyView(),isActive: $navigating) {
                        EmptyView()
                    }
                }
            }
        }
//        .overlay {
//            if isLoading {
//                LoadingGameView()
//            }
//        }
    }
    
    func startLoading() {
        navigating = true
    }
}


#Preview {
    PlayMenuView()
        .environmentObject(ViewController())
        .modelContainer(for: [DeckListModel.self])
}
