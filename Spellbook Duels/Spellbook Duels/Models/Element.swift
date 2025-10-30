//
//  Element.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 10/29/25.
//

import SwiftUI


enum Element: String, Codable {
    case FIRE, WATER, EARTH, AIR
}

struct ElementColorDict {
    static let elementColors : [Element: Color] = [Element.FIRE: Color("FireColor"), Element.WATER: Color("WaterColor"), Element.EARTH: Color("EarthColor"), Element.AIR: Color("AirColor")]
}
