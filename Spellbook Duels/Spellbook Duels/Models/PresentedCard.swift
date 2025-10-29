//
//  PresentedCard.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 10/27/25.
//

import Foundation
import UIKit

enum Element {
    case FIRE, WATER, EARTH, AIR
}

struct PresentedCard {
    let name: String
    let text: String
    let type: String
    let cost: String
    let costVal: Int
    let element: Element
    let image: UIImage
    let icon: UIImage
    let cardCode: String
    let Strength: Int?
    let duration: Int?
    let hasActivated: Bool
    let numTargets: Int?
}
