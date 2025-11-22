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
    private var ref: DatabaseReference = Database.database().reference()

}
