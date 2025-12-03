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
    var imageName: String?
    var iconName: String?
    var cardCode: String
    var Strength: Int?
    var duration: Int?
    var speed: Int?
    var hasActivated: Bool
    var numTargets: Int?
    var targetTypes: [(CardType, PlayerSide?)]?
    var needsNselect: Bool = false
    
    init(name: String, text: String, type: CardType, cost: String, costVal: Int, element: Element, image: String?, icon: String?, cardCode: String, Strength: Int?, duration: Int?, speed: Int?, hasActivated: Bool, numTargets: Int?, targetTypes: [(CardType, PlayerSide?)]?) {
        self.name = name
        self.text = text
        self.type = type
        self.cost = cost
        self.costVal = costVal
        self.element = element
        self.imageName = image
        self.iconName = icon
        self.cardCode = cardCode
        self.Strength = Strength
        self.duration = duration
        self.speed = speed
        self.hasActivated = hasActivated
        self.numTargets = numTargets
        self.targetTypes = targetTypes
    }
    
    init(name: String, text: String, type: CardType, cost: String, costVal: Int, element: Element, image: String?, icon: String?, cardCode: String, Strength: Int?, duration: Int?, speed: Int?, hasActivated: Bool, numTargets: Int?, targetTypes: [(CardType, PlayerSide?)]?, needsNSelect: Bool?) {
        self.name = name
        self.text = text
        self.type = type
        self.cost = cost
        self.costVal = costVal
        self.element = element
        self.imageName = image
        self.iconName = icon
        self.cardCode = cardCode
        self.Strength = Strength
        self.duration = duration
        self.speed = speed
        self.hasActivated = hasActivated
        self.numTargets = numTargets
        self.targetTypes = targetTypes
        if needsNSelect != nil { self.needsNselect = needsNSelect! }
    }
    
    var uiImage: UIImage? {
        guard let imageName = imageName else { return nil }
        return UIImage(named: imageName)
    }
    
    var iconUIImage: UIImage? {
        guard let iconName = iconName else { return nil }
        return UIImage(named: iconName)
    }
}
