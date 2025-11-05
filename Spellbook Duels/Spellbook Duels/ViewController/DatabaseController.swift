//
//  DatabaseController.swift
//  Spellbook Duels
//
//  Created by Rocky Williams on 11/4/25.
//

import Foundation
import FirebaseDatabase
import Combine

class ViewModel: Observable {
    @Published var num: Int = 1 // placeholder variable so that it conforms to observable
    private var ref: DatabaseReference = Database.database().reference()

}
