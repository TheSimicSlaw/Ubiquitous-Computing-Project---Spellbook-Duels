//
//  ViewController.swift
//  Spellbook Duels
//
//  Created by Rocky Williams on 11/22/25.
//

import Foundation
import Combine

class ViewController: ObservableObject {
    @Published var playerName: String? = nil
    @Published var isSearching: Bool = false
    @Published var isWaiting: Bool = false
    @Published var inGame: Bool = false
    @Published var matchCode: String = ""
}
