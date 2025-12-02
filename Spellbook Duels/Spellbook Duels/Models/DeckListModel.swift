//
//  DeckListModel.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 10/29/25.
//

import Foundation
import SwiftData

enum DeckFormattingError: Error {
    case wrongNumElements(deckName: String)
}

@Model
class DeckListModel {
    var deckName: String
    var cardList: [String]
    var cardCounts: [String : Int]
    var deckElements: [Element]
    
    init(deckname: String, cardList: [String], cardCounts: [String : Int], deckElements: [Element]) /*throws*/ {
        self.deckName = deckname
        self.cardList = cardList
        self.cardCounts = cardCounts
        self.deckElements = deckElements
    }
}

extension DeckListModel {
    static let counterburnPrecon = DeckListModel(deckname: "Counterburn", cardList: ["WIN", "FAS", "FSP", "FGR", "FPU", "WSL", "WSC", "WRE", "FBL", "FFI", "FIR", "WHY", "FFL", "FWA", "FOU"], cardCounts: ["WIN": 4, "FAS": 4, "FSP": 4, "FGR": 4, "FPU": 4, "WSL": 4, "WSC": 4, "WRE": 4, "FBL": 4, "FFI": 4, "FIR": 4, "WHY": 4, "FFL": 4, "FWA": 4, "FOU": 4], deckElements: [Element.FIRE, Element.WATER])
    
    @MainActor
    static var precons: ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: DeckListModel.self, configurations: configuration)
        
        container.mainContext.insert(DeckListModel(deckname: "Counterburn", cardList: ["WIN", "FAS", "FSP", "FGR", "FPU", "WSL", "WSC", "WRE", "FBL", "FFI", "FIR", "WHY", "FFL", "FWA", "FOU"], cardCounts: ["WIN": 4, "FAS": 4, "FSP": 4, "FGR": 4, "FPU": 4, "WSL": 4, "WSC": 4, "WRE": 4, "FBL": 4, "FFI": 4, "FIR": 4, "WHY": 4, "FFL": 4, "FWA": 4, "FOU": 4], deckElements: [Element.FIRE, Element.WATER]))
        container.mainContext.insert(DeckListModel(deckname: "Counterburn 2", cardList: ["WIN", "FAS", "FSP", "FGR", "FPU", "WSL", "WSC", "WRE", "FBL", "FFI", "FIR", "WHY", "FFL", "FWA", "FOU"], cardCounts: ["WIN": 4, "FAS": 4, "FSP": 4, "FGR": 4, "FPU": 4, "WSL": 4, "WSC": 4, "WRE": 4, "FBL": 4, "FFI": 4, "FIR": 4, "WHY": 4, "FFL": 4, "FWA": 4, "FOU": 4], deckElements: [Element.FIRE, Element.WATER]))
        container.mainContext.insert(DeckListModel(deckname: "Earth/Air", cardList: ["WIN", "FAS", "FSP", "FGR", "FPU", "WSL", "WSC", "WRE", "FBL", "FFI", "FIR", "WHY", "FFL", "FWA", "FOU"], cardCounts: ["WIN": 4, "FAS": 4, "FSP": 4, "FGR": 4, "FPU": 4, "WSL": 4, "WSC": 4, "WRE": 4, "FBL": 4, "FFI": 4, "FIR": 4, "WHY": 4, "FFL": 4, "FWA": 4, "FOU": 4], deckElements: [Element.AIR, Element.EARTH]))
        try? container.mainContext.save()
        
        return container
    }
    
    var totalCards: Int {
        return self.cardCounts.values.reduce(0, +)
    }
}
