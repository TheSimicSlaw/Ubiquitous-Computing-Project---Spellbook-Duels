//
//  DecksMenuView.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 10/3/25.
//

import SwiftUI
import SwiftData

struct DecksMenuView: View {
    @Environment(\.modelContext) var modelContext
    @Query var decks: [DeckListModel]
    
    @State private var path = NavigationPath()
    @State private var selectedDeck: DeckListModel? = nil
    
    @State private var askingNewDeckDetails = false
    @State private var newDeckName: String = ""
    @State private var newDeckElements: [Element] = []
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    // MARK: Body
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color("MenuBackgroundColor").ignoresSafeArea()
                
                VStack {
                    ZStack {
                        Rectangle()
                            .fill(Color("AccentTwo"))
                            .frame(width:425, height:190)
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
                                Button {
                                    selectedDeck = deck
                                    path.append(deck)
                                } label: {
                                    ZStack {
                                        VStack {
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
                            Button {
                                newDeckName = ""
                                newDeckElements = []
                                askingNewDeckDetails = true
                                //newDeck = DeckListModel(deckname: "", cardList: [], cardCounts: [], deckElements: <#T##[Element]#>)
                            } label: {
                                Image(systemName: "plus")
                                    .resizable()
                                    .scaledToFit()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(25)
                                    .foregroundStyle(.black)
                                    .frame(width:200, height:300)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color("AccentOne")))
                                    
                            }
                        }
                    }
                }
                .newPopup(isPresented: $askingNewDeckDetails){
                    newDeckPopupContent
                }
                .navigationDestination(for: DeckListModel.self) { selecteddeck in
                    DeckEditorView(deck: selecteddeck)
                }
            }
        }
        
    }
    
    
    // MARK: Popup Content
    
    private var newDeckPopupContent: some View {
        GeometryReader { geo in
            let maxWidth = min(geo.size.width * 0.8, 380)
            let elementDiamondHeight = geo.size.height * 0.35
            
            
            VStack(spacing:12) {
                Text("New Deck")
                    .foregroundStyle(Color("AccentOne"))
                    .font(.custom("InknutAntiqua-Bold", size: 24))
                
                elementButtonDiamond(height: elementDiamondHeight)
                    .padding(.bottom, 8)
                
                TextField("Deck Name", text: $newDeckName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 8)
                
                HStack {
                    Button {
                        newDeckName = ""
                        newDeckElements = []
                        askingNewDeckDetails = false
                    } label: {
                        Text("Cancel").foregroundStyle(Color("AccentOne"))
                            .font(.custom("InknutAntiqua-Regular", size: 18))
                    }

                    Spacer()

                    Button {
                        if decks.contains(where: {$0.deckName==newDeckName}) {
                            newDeckName = newDeckName + " (1)"
                        }
                        let deck = DeckListModel(deckname: newDeckName, cardList: [], cardCounts: [:], deckElements: newDeckElements)
                        modelContext.insert(deck)
                        selectedDeck = deck
                        askingNewDeckDetails = false
                        path.append(deck)
                    } label: {
                        Text("Create")
                            .foregroundStyle(Color("AccentOne"))
                            .opacity((newDeckElements.count < 2 || newDeckName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? 0.5 : 1.0)
                            .font(.custom("InknutAntiqua-Regular", size: 18))
                    }
                    .disabled(
                        newDeckElements.count < 2 || newDeckName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
                }
                //.padding(.top, 8)
            }
            .frame(width: maxWidth)
            .padding(.vertical, 16)
            .frame(
                width: geo.size.width,
                height: geo.size.height,
                alignment: .center
            )
        }
        .frame(height: 260)
    }
    
    private func elementButtonDiamond(height: CGFloat) -> some View {
        GeometryReader { geo in
            let size = min(geo.size.width, height)
            let centerX = size / 2
            let centerY = size / 2
            
            ZStack {
                elementButton(.FIRE)
                    .position(x: centerX, y: centerY - size * 0.35)
                
                elementButton(.EARTH)
                    .position(x: centerX - size * 0.35, y: centerY)
                
                elementButton(.AIR)
                    .position(x: centerX + size * 0.35, y: centerY)
                
                elementButton(.WATER)
                    .position(x: centerX, y: centerY + size * 0.35)
            }
            .frame(width: size, height: size)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: height)
    }
    
    private func elementButton(_ element: Element) -> some View {
        let isOn = newDeckElements.contains(element)
        let baseColor = ElementColorDict.elementColors[element] ?? .gray
        
        return Button {
            toggleElement(element)
        } label: {
            ZStack {
                Circle()
                    .fill(baseColor)
                    .opacity(isOn ? 1.0 : 0.5)
                    .overlay(
                        Circle()
                            .stroke(.white, lineWidth: isOn ? 4.0 : 0.0)
                    )
                    .shadow(radius: isOn ? 8 : 2)
            }
            .frame(width: 30, height: 30)
            .scaleEffect(isOn ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isOn)
        }
    }
    
    private func toggleElement(_ element: Element) {
        if let index = newDeckElements.firstIndex(of: element) {
            newDeckElements.remove(at: index)
        } else {
            if newDeckElements.count < 2 {
                newDeckElements.append(element)
            } else {
                newDeckElements[0] = newDeckElements[1]
                newDeckElements[1] = element
            }
        }
    }
}


#Preview {
    DecksMenuView()
        //.modelContainer(for: [DeckListModel.self])
        .modelContainer(DeckListModel.precons)
}

