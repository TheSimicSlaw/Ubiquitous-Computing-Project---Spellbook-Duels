//
//  LoadingGameView.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 10/3/25.
//

import SwiftUI

struct LoadingGameView: View {
    @EnvironmentObject var viewController: ViewController
    @EnvironmentObject var firebaseController: DatabaseController
    @EnvironmentObject var gameEngine: GameEngine
    var body: some View {
        ZStack {
            Color.accentOne
                .ignoresSafeArea()
            if (firebaseController.opponent.id != "") {
                Text("Connected")
                    .font(.custom("InknutAntiqua-Light", size: 25))
                    .onAppear {
                        viewController.isSearching = false
                        viewController.isWaiting = false
                        //viewController.inGame = true
                        gameEngine.getOpponentBoard(matchCode: viewController.matchCode, opponentID: firebaseController.opponent.id)
                    }
            } else {
                VStack {
                    Text("Loading...")
                        .font(.custom("InknutAntiqua-Light", size: 25))
                    Text("Match Code: \(viewController.matchCode)")
                        .font(.custom("InknutAntiqua-Light", size: 15))
                }
            }
        }
    }
}

#Preview {
    LoadingGameView()
        .environmentObject(ViewController())
        .environmentObject(DatabaseController())
        .environmentObject(GameEngine())
}
