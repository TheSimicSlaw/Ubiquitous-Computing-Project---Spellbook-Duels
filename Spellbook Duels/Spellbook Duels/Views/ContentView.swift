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
    @EnvironmentObject var viewController: ViewController
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
    }
}

#Preview {
    ContentView()
        .environmentObject(ViewController())
        .modelContainer(DeckListModel.precons)
}
