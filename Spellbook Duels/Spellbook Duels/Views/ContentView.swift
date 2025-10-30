//
//  ContentView.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 10/3/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query var decks: [DeckListModel]
    
    
    var body: some View {
       NavigationStack() {
            TabView {
                PlayMenuView()
                    .tabItem {
                        Label("Duel", systemImage: "wand.and.outline")
                    }
                    
                DecksMenuView()
                    .tabItem {
                        Label("Library", systemImage: "book")
                    }
            }
        }
       .task {
           if decks.isEmpty {
               modelContext.insert(DeckListModel(deckname: "Counterburn", cardList: ["WIN", "FAS", "FSP", "FGR", "FPU", "WSL", "WSC", "WRE", "FBL", "FFI", "FIR", "WHY", "FFL", "FWA", "FOU"], cardCounts: ["WIN": 4, "FAS": 4, "FSP": 4, "FGR": 4, "FPU": 4, "WSL": 4, "WSC": 4, "WRE": 4, "FBL": 4, "Fire Wand": 4, "FIR": 4, "WHY": 4, "FFL": 4, "FWA": 4, "FOU": 4], deckElements: [Element.FIRE, Element.WATER]))
               modelContext.insert(DeckListModel(deckname: "Counterburn 2", cardList: ["WIN", "FAS", "FSP", "FGR", "FPU", "WSL", "WSC", "WRE", "FBL", "FFI", "FIR", "WHY", "FFL", "FWA", "FOU"], cardCounts: ["WIN": 4, "FAS": 4, "FSP": 4, "FGR": 4, "FPU": 4, "WSL": 4, "WSC": 4, "WRE": 4, "FBL": 4, "Fire Wand": 4, "FIR": 4, "WHY": 4, "FFL": 4, "FWA": 4, "FOU": 4], deckElements: [Element.FIRE, Element.WATER]))
               modelContext.insert(DeckListModel(deckname: "Earth/Air", cardList: ["WIN", "FAS", "FSP", "FGR", "FPU", "WSL", "WSC", "WRE", "FBL", "FFI", "FIR", "WHY", "FFL", "FWA", "FOU"], cardCounts: ["WIN": 4, "FAS": 4, "FSP": 4, "FGR": 4, "FPU": 4, "WSL": 4, "WSC": 4, "WRE": 4, "FBL": 4, "Fire Wand": 4, "FIR": 4, "WHY": 4, "FFL": 4, "FWA": 4, "FOU": 4], deckElements: [Element.AIR, Element.EARTH]))
               try? modelContext.save()
           }
       }
    }
}

#Preview {
    ContentView()
        .modelContainer(DeckListModel.precons)
}
