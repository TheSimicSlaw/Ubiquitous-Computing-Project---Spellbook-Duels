//
//  ContentView.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 10/3/25.
//

import SwiftUI

struct ContentView: View {
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
}
