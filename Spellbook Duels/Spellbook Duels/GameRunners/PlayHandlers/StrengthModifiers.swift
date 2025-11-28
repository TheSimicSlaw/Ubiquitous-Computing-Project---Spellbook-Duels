//
//  StrengthModifiers.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 11/27/25.
//

import SwiftUI

typealias StrengthModifier = (_ strength: inout Int, _ card: PresentedCardModel, _ owner: PlayerSide) -> Void

struct StrengthModifierEntry {
    let id: UUID
    let position: CardSlot
    let handler: StrengthModifier
}

struct StrengthModifierStore {
    private(set) var entries: [StrengthModifierEntry] = []

    @discardableResult
    mutating func add(at position: CardSlot, _ modifier: @escaping StrengthModifier) -> UUID {
        let id = UUID()
        entries.append(
            StrengthModifierEntry(id: id, position: position, handler: modifier)
        )
        return id
    }

    mutating func remove(_ id: UUID) {
        entries.removeAll { $0.id == id }
    }

    mutating func removeAll(at position: CardSlot) {
        entries.removeAll { $0.position == position }
    }
}

extension GameEngine {
    struct StrengthGetters {
        var board: BoardModel
        var strengthModifierStore: StrengthModifierStore = StrengthModifierStore()
        
        init(board: BoardModel) {
            self.board = board
        }
        
        var playerCurseStrength: Int? {
            if let card = PresentedCardModel.cardByCode[self.board.playerCurse.card] {
                var strength = card.Strength!
                for entry in strengthModifierStore.entries {
                    entry.handler(&strength, card, .player)
                }
                return strength
            } else {
                return nil
            }
        }
        var playerWardStrength: Int? {
            if let card = PresentedCardModel.cardByCode[self.board.playerWard.card] {
                var strength = card.Strength!
                for entry in strengthModifierStore.entries {
                    entry.handler(&strength, card, .player)
                }
                return strength
            } else {
                return nil
            }
        }
        var playerSnapStrength: Int? {
            if let card = PresentedCardModel.cardByCode[self.board.playerSnap.card] {
                var strength = card.Strength!
                for entry in strengthModifierStore.entries {
                    entry.handler(&strength, card, .player)
                }
                return strength
            } else {
                return nil
            }
        }
        var opponentCurseStrength: Int? {
            if let card = PresentedCardModel.cardByCode[self.board.opponentCurse.card] {
                var strength = card.Strength!
                for entry in strengthModifierStore.entries {
                    entry.handler(&strength, card, .opponent)
                }
                return strength
            } else {
                return nil
            }
        }
        var opponentWardStrength: Int? {
            if let card = PresentedCardModel.cardByCode[self.board.opponentWard.card] {
                var strength = card.Strength!
                for entry in strengthModifierStore.entries {
                    entry.handler(&strength, card, .opponent)
                }
                return strength
            } else {
                return nil
            }
        }
        var opponentSnapStrength: Int? {
            if let card = PresentedCardModel.cardByCode[self.board.opponentSnap.card] {
                var strength = card.Strength!
                for entry in strengthModifierStore.entries {
                    entry.handler(&strength, card, .opponent)
                }
                return strength
            } else {
                return nil
            }
        }
    }
}
