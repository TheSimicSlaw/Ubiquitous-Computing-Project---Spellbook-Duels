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
    @EnvironmentObject var gameEngine: GameEngine
    @Query var decks: [DeckListModel]
    
    var body: some View {
        if (viewController.inGame) {
            GameFieldView()
        } else if (viewController.isWaiting || viewController.isSearching) {
            LoadingGameView()
        } else {
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
}

#Preview {
    ContentView()
        .environmentObject(ViewController())
        .environmentObject(GameEngine())
        .environmentObject(DatabaseController())
        .modelContainer(DeckListModel.precons)
}
