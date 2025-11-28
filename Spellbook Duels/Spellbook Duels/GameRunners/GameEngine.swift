//
//  GameEngine.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 11/26/25.
//

import Foundation

final class GameEngine {
    var board: BoardModel
    
    init(initialBoard: BoardModel = BoardModel()) {
        self.board = initialBoard
    }
}
