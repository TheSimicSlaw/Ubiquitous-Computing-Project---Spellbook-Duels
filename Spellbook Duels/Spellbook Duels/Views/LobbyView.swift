//
//  LobbyView.swift
//  Spellbook Duels
//
//  Created by Rocky Williams on 11/30/25.
//

import SwiftUI

struct LobbyView: View {
    @EnvironmentObject var firebaseController: DatabaseController
    @EnvironmentObject var viewController: ViewController
    @EnvironmentObject var gameEngine: GameEngine
    
    @State private var createMatchCode: String = ""
    @State private var joinMatchCode: String = ""
    @State private var showCreateField = false
    @State private var showJoinField = false
    
    var body: some View {
        ZStack {
            Color("MenuBackgroundColor")
                .ignoresSafeArea()
            
            VStack {
                Button {
                    showCreateField = true
                } label: {
                    Text("Create Match")
                        .font(.title)
                        .foregroundStyle(.black)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("AccentOne"))
                        }
                }
                
                if (showCreateField) {
                    HStack {
                        TextField("Create Match Code", text: $createMatchCode)
                        Button("Submit") {
                            let s = createMatchCode.trimmingCharacters(in: .whitespacesAndNewlines)
                            firebaseController.createMatch(matchCode: s)
                            firebaseController.writeBoard(matchCode: s, dict: gameEngine.board.boardToDictionary())
                            viewController.matchCode = s
                            createMatchCode = ""
                            viewController.isWaiting = true
                        }
                    }
                    .padding()
                }
                
                
                Button {
                    showJoinField = true
                } label: {
                    Text("Join Match")
                        .font(.title)
                        .foregroundStyle(.black)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color("AccentOne"))
                        }
                }
                if (showJoinField) {
                    HStack {
                        TextField("Enter Match Code", text: $joinMatchCode)
                        Button("Submit") {
                            let s = joinMatchCode.trimmingCharacters(in: .whitespacesAndNewlines)
                            firebaseController.joinMatch(matchCode: s)
                            firebaseController.writeBoard(matchCode: s, dict: gameEngine.board.boardToDictionary())
                            viewController.matchCode = s
                            joinMatchCode = ""
                            viewController.isSearching = true
                        }
                    }
                    .padding()
                    
                }
            }
            
        }
    }
}

#Preview {
    LobbyView()
        .environmentObject(DatabaseController())
        .environmentObject(ViewController())
        .environmentObject(GameEngine())
}
