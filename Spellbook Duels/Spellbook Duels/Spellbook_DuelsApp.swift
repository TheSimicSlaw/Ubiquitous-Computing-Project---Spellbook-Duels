//
//  Spellbook_DuelsApp.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 10/3/25.
//

import SwiftUI
import SwiftData

@main
struct Spellbook_DuelsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: DeckListModel.self)
                //.modelContainer(for: PresentedCardModel.self)
        }
    }
}
