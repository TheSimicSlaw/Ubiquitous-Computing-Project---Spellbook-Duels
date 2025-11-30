//
//  Spellbook_DuelsApp.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 10/3/25.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseDatabase


@main
struct Spellbook_DuelsApp: App {
    init() {
        FirebaseApp.configure()
    }
    @StateObject var viewController = ViewController()
    @StateObject var firebaseController = DatabaseController()
    @StateObject var gameEngine = GameEngine()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: DeckListModel.self)
                .environmentObject(viewController)
                .environmentObject(firebaseController)
                .environmentObject(gameEngine)
        }
    }
}
