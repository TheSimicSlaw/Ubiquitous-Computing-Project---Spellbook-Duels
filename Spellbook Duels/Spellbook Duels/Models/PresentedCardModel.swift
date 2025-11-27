//
//  PresentedCardModel.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 10/27/25.
//

import Foundation
import UIKit
import SwiftData

enum CardType: String, Codable {
    case jinx, counterspell, curse, ward, charm, relic, potion
}

class PresentedCardModel: Identifiable {
    var name: String
    var text: String
    var type: CardType
    var cost: String
    var costVal: Int
    var element: Element
    var image: UIImage?
    var icon: UIImage?
    var cardCode: String
    var Strength: Int?
    var duration: Int?
    var speed: Int?
    var hasActivated: Bool
    var numTargets: Int?
    
    init(name: String, text: String, type: CardType, cost: String, costVal: Int, element: Element, image: UIImage?, icon: UIImage?, cardCode: String, Strength: Int?, duration: Int?, speed: Int?, hasActivated: Bool, numTargets: Int?) {
        self.name = name
        self.text = text
        self.type = type
        self.cost = cost
        self.costVal = costVal
        self.element = element
        self.image = image
        self.icon = icon
        self.cardCode = cardCode
        self.Strength = Strength
        self.duration = duration
        self.speed = speed
        self.hasActivated = hasActivated
        self.numTargets = numTargets
    }
}
