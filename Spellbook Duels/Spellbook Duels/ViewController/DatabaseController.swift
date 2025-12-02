//
//  DatabaseController.swift
//  Spellbook Duels
//
//  Created by Rocky Williams on 11/4/25.
//

import Foundation
import FirebaseDatabase
import Combine

class DatabaseController: ObservableObject {
    @Published var player = Player()
    @Published var opponent = Player()
    @Published var turn: String = "" // will store the id of whoever's turn it is
    //@Published var playerHand: [String] = [] // stores all the cards in the players hand

    //@Published var discardPile: [String] = [] // will store the codes of the cards in the discard pile
    //@Published var spellBook: [String] = []
    
    
    //@Published var playerCardZones: [String: String] = [:] // ["zone name" : "card occupying the zone"]
    //@Published var opponentCardZones: [String: String] = [:]
    
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

        writeBoard(matchCode: matchCode)
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
        playersRef.observeSingleEvent(of: .value) { snapshot in
            var players: [String] = []
            var names: [String] = []
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    players.append(snapshot.key)
                    
                    guard let value = snapshot.value as? [String: Any] else {continue}
                    let name = value["name"] as? String ?? "Unknown"
                    names.append(name)
                }
            }
            if (players.count == 2) {
                self.opponent.id = players[0]
                self.opponent.name = names[0]
            }
        }
    }
    
    func hostGetOpponent(matchCode: String) {
        let playersRef = self.ref.child("matches/\(matchCode)/players")
        let handler = playersRef.observe(.value) {snapshot in
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
                        break
                    }
                }
            }
        }
    }
    
    func writeBoard(boardModel: BoardModel = BoardModel(), matchCode: String) {
        let boardRef = self.ref.child("matches/\(matchCode)/board")
        
        do {
            let data = try boardModel.toDictionary()
            boardRef.setValue(data)
        } catch {
            print("Error converting board into a dictionary")
        }
    }
    
    func endMatch(matchCode: String) {
        self.ref.child("matches/\(matchCode)").removeValue()
    }
}
