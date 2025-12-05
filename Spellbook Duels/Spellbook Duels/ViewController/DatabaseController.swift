//
//  DatabaseController.swift
//  Spellbook Duels
//
//  Created by Rocky Williams on 11/4/25.
//

import Foundation
import FirebaseDatabase
import Combine

@MainActor
class DatabaseController: ObservableObject {
    @Published var player = Player()
    @Published var opponent = Player()
    @Published var inGame = false
    @Published var turn: String = "" // will store the id of whoever's turn it is
    
    private var ref: DatabaseReference = Database.database().reference()

    func createMatch(matchCode: String) {
        let newMatchRef = self.ref.child("matches/\(matchCode)")
        newMatchRef.setValue([
            "code": "\(matchCode)",
            "players": nil,
            "open": true
        ])
        
        let newPlayerRef = newMatchRef.child("players").childByAutoId()
        
        if let playerID = newPlayerRef.key {
            self.player.id = playerID
        }
        
        newPlayerRef.setValue([
            "name": "\(self.player.name)"
        ])

        hostGetOpponent(matchCode: matchCode)
    }
    
    func joinMatch(matchCode: String) {
        let playersRef = self.ref.child("matches/\(matchCode)/players").childByAutoId()
        
        if let playerID = playersRef.key {
            self.player.id = playerID
        }
        
        playersRef.setValue([
            "name": "\(self.player.name)"
        ])
        
        self.ref.child("matches/\(matchCode)/open").setValue(false)
        self.guestGetOpponent(matchCode: matchCode)
    }
    
    func guestGetOpponent(matchCode: String) {
        let playersRef = self.ref.child("matches/\(matchCode)/players")
        playersRef.observe(.value) { snapshot in
            var players: [String] = []
            var names: [String] = []
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    players.append(snapshot.key)
                    
                    guard let value = snapshot.value as? [String: Any] else {continue}
                    let name = value["name"] as? String ?? "Unknown"
                    names.append(name)
                } else {
                    self.inGame = false
                }
            }
            if (players.count == 2) {
                self.opponent.id = players[0]
                self.opponent.name = names[0]
                self.inGame = true
            }
        }
        listenForConcede(matchCode: matchCode)
    }
    
    func hostGetOpponent(matchCode: String) {
        let playersRef = self.ref.child("matches/\(matchCode)/players")
        playersRef.observe(.value) {snapshot in
            var players: [String] = []
            var names: [String] = []
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot, let value = snapshot.value as? [String: Any] {
                    players.append(snapshot.key)
                    let name = value["name"] as? String ?? "Unknown"
                    names.append(name)
                    print(snapshot.key)
                    
                    if (players.count > 1) {
                        self.opponent.id = players[1]
                        self.opponent.name = names[1]
                        self.inGame = true
                        break
                    }
                }
            }
        }
        listenForConcede(matchCode: matchCode)
    }
    
    func writeBoard(matchCode: String, dict: [String: Any]) {
        if player.id == "" {
            return
        }
        let boardRef = self.ref.child("matches/\(matchCode)/players/\(player.id)/board")
        boardRef.setValue(dict)
    }
    
    func listenForConcede(matchCode: String) {
        self.ref.child("matches/\(matchCode)/players").observe(.childRemoved) {snapshot in
            self.inGame = false
        }
    }
    
    func endMatch(matchCode: String) {
        //self.ref.child("matches/\(matchCode)/")
        self.inGame = false
        self.ref.child("matches/\(matchCode)/players/\(player.id)").removeValue()
        self.ref.child("matches/\(matchCode)").removeValue()
    }
    
    
//    func getOpponentBoard(matchCode: String, opponentID: String) -> [String: Any] {
//        if opponentID == "" {
//           return [:]
//        }
//       
//        let oppBoardRef = self.ref.child("matches/\(matchCode)/\(opponentID)/board")
//        
//        _ = oppBoardRef.observe(.value) {snapshot in
//            if let dict = snapshot.value as? [String: Any] {
//                self.boardFromFirebase = dict
//            }
//        }
//
//    }
}
