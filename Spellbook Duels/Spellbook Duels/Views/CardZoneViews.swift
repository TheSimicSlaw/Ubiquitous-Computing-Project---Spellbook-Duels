//
//  CardZoneViews.swift
//  Spellbook Duels
//
//  Created by Rocky Williams on 11/28/25.
//

import SwiftUI

struct IconSizes {
    static func getIconSize(zone: CardZone) -> CGFloat {
        if zone == .snap { return 90 }
        return 70
    }
}

struct CurseCardView: View {
    @EnvironmentObject var gameEngine: GameEngine
    @State private var showDetails: Bool = false
    
    var player: PlayerSide
    
    var body: some View {
        if let card = PresentedCardModel.cardByCode[gameEngine.board.getSlot(player, .curse).card] {
            Menu {
                Button("View Details") {
                    showDetails = true
                }
                
            } label: {
                if let uiImage = card.iconUIImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: IconSizes.getIconSize(zone: .curse), height: IconSizes.getIconSize(zone: .curse))
//                        .shadow(color: .yellow, radius: 10)
//                        .shadow(color: .yellow, radius: 10)
                        //.shadow(color: .yellow, radius: 10)
                        .sheet(isPresented: $showDetails) {
                            DetailedCardView(card: card)
                        }
                } else {
                    VStack(spacing: 8) {
                        Text("Missing image")
                            .font(.headline)
                        Text(card.imageName ?? "(nil imageName)")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .sheet(isPresented: $showDetails) {
                        DetailedCardView(card: card)
                    }
                }
            }
        } else {
            Rectangle()
                .stroke(.white, lineWidth: 2)
                .frame(width: IconSizes.getIconSize(zone: .curse), height: IconSizes.getIconSize(zone: .curse))
        }
    }
}

struct SnapCardView: View {
    @EnvironmentObject var gameEngine: GameEngine
    @State private var showDetails: Bool = false
    
    var player: PlayerSide
    
    var body: some View {
        if let card = PresentedCardModel.cardByCode[gameEngine.board.getSlot(player, .snap).card] {
            Menu {
                Button("View Details") {
                    showDetails = true
                }
                
            } label: {
                if let uiImage = card.iconUIImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: IconSizes.getIconSize(zone: .snap), height: IconSizes.getIconSize(zone: .snap))
//                        .shadow(color: .yellow, radius: 10)
//                        .shadow(color: .yellow, radius: 10)
                        //.shadow(color: .yellow, radius: 10)
                        .sheet(isPresented: $showDetails) {
                            DetailedCardView(card: card)
                        }
                } else {
                    VStack(spacing: 8) {
                        Text("Missing image")
                            .font(.headline)
                        Text(card.imageName ?? "(nil imageName)")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .sheet(isPresented: $showDetails) {
                        DetailedCardView(card: card)
                    }
                }
            }
        } else {
            Rectangle()
                .stroke(.white, lineWidth: 2)
                .frame(width: IconSizes.getIconSize(zone: .snap), height: IconSizes.getIconSize(zone: .snap))
        }
    }
}

struct WardCardView: View {
    @EnvironmentObject var gameEngine: GameEngine
    @State private var showDetails: Bool = false
    
    var player: PlayerSide
    
    var body: some View {
        if let card = PresentedCardModel.cardByCode[gameEngine.board.getSlot(player, .ward).card] {
            Menu {
                Button("View Details") {
                    showDetails = true
                }
                
            } label: {
                if let uiImage = card.iconUIImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: IconSizes.getIconSize(zone: .ward), height: IconSizes.getIconSize(zone: .ward))
//                        .shadow(color: .yellow, radius: 10)
//                        .shadow(color: .yellow, radius: 10)
                        //.shadow(color: .yellow, radius: 10)
                        .sheet(isPresented: $showDetails) {
                            DetailedCardView(card: card)
                        }
                } else {
                    VStack(spacing: 8) {
                        Text("Missing image")
                            .font(.headline)
                        Text(card.imageName ?? "(nil imageName)")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .sheet(isPresented: $showDetails) {
                        DetailedCardView(card: card)
                    }
                }
            }
        } else {
            Rectangle()
                .stroke(.white, lineWidth: 2)
                .frame(width: IconSizes.getIconSize(zone: .ward), height: IconSizes.getIconSize(zone: .ward))
        }
    }
}

struct CharmCardView: View {
    @EnvironmentObject var gameEngine: GameEngine
    @State private var showDetails: Bool = false
    
    var player: PlayerSide
    
    var body: some View {
        if let card = PresentedCardModel.cardByCode[gameEngine.board.getSlot(player, .charm).card] {
            Menu {
                Button("View Details") {
                    showDetails = true
                }
                
            } label: {
                if let uiImage = card.iconUIImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: IconSizes.getIconSize(zone: .charm), height: IconSizes.getIconSize(zone: .charm))
//                        .shadow(color: .yellow, radius: 10)
//                        .shadow(color: .yellow, radius: 10)
                        //.shadow(color: .yellow, radius: 10)
                        .sheet(isPresented: $showDetails) {
                            DetailedCardView(card: card)
                        }
                } else {
                    VStack(spacing: 8) {
                        Text("Missing image")
                            .font(.headline)
                        Text(card.imageName ?? "(nil imageName)")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .sheet(isPresented: $showDetails) {
                        DetailedCardView(card: card)
                    }
                }
            }
        } else {
            Rectangle()
                .stroke(.white, lineWidth: 2)
                .frame(width: IconSizes.getIconSize(zone: .curse), height: IconSizes.getIconSize(zone: .curse))
        }
    }
}

struct RelicCardView: View {
    @EnvironmentObject var gameEngine: GameEngine
    @State private var showDetails: Bool = false
    
    var player: PlayerSide
    
    var body: some View {
        if let card = PresentedCardModel.cardByCode[gameEngine.board.getSlot(player, .relic).card] {
            Menu {
                Button("View Details") {
                    showDetails = true
                }
                if (gameEngine.activePlayer == .player && gameEngine.phase == .action) {
                    Button("Activate") {
                        
                    }
                }
                
            } label: {
                if let uiImage = card.iconUIImage {
                    VStack(spacing: -5) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: IconSizes.getIconSize(zone: .relic), height: IconSizes.getIconSize(zone: .relic))
//                            .shadow(color: .yellow, radius: 10)
//                            .shadow(color: .yellow, radius: 10)
                            //.shadow(color: .yellow, radius: 10)
                            .sheet(isPresented: $showDetails) {
                                DetailedCardView(card: card)
                            }
                        if gameEngine.phase == .action && gameEngine.noAbilitiesOnStack {
                            Button {
                                
                            } label: {
                                ZStack(alignment: .center) {
                                    Rectangle()
                                        .frame(width: IconSizes.getIconSize(zone: .relic), height: IconSizes.getIconSize(zone: .relic)/4)
                                        .foregroundStyle(ElementColorDict.elementColors[card.element]!)
                                    Text("Activate?")
                                        .font(.custom("InknutAntiqua-Bold", size: 11))
                                        .foregroundStyle(.accentOne)
                                }
                            }
                        }
                    }
                } else {
                    VStack(spacing: 8) {
                        Text("Missing image")
                            .font(.headline)
                        Text(card.imageName ?? "(nil imageName)")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .sheet(isPresented: $showDetails) {
                        DetailedCardView(card: card)
                    }
                }
            }
        } else {
            Rectangle()
                .stroke(.white, lineWidth: 2)
                .frame(width: IconSizes.getIconSize(zone: .relic), height: IconSizes.getIconSize(zone: .relic))
        }
    }
}

struct PotionCardView: View {
    @EnvironmentObject var gameEngine: GameEngine
    @State private var showDetails: Bool = false
    
    var player: PlayerSide
    
    var body: some View {
        if let card = PresentedCardModel.cardByCode[gameEngine.board.getSlot(player, .potion).card] {
            Menu {
                Button("View Details") {
                    showDetails = true
                }
                if (gameEngine.activePlayer == .player && gameEngine.phase == .action) {
                    Button("Activate") {
                        
                    }
                }
            } label: {
                if let uiImage = card.iconUIImage {
                    VStack(spacing: -5) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: IconSizes.getIconSize(zone: .potion), height: IconSizes.getIconSize(zone: .potion))
//                            .shadow(color: .yellow, radius: 10)
//                            .shadow(color: .yellow, radius: 10)
                            //.shadow(color: .yellow, radius: 10)
                            .sheet(isPresented: $showDetails) {
                                DetailedCardView(card: card)
                            }
                        if gameEngine.isAskingPlayerToActivate {
                            Button {
                                
                            } label: {
                                ZStack(alignment: .center) {
                                    Rectangle()
                                        .frame(width: IconSizes.getIconSize(zone: .relic), height: IconSizes.getIconSize(zone: .relic)/4)
                                        .foregroundStyle(ElementColorDict.elementColors[card.element]!)
                                    Text("Activate?")
                                        .font(.custom("InknutAntiqua-Bold", size: 11))
                                        .foregroundStyle(.accentOne)
                                }
                            }
                        }
                    }
                } else {
                    VStack(spacing: 8) {
                        Text("Missing image")
                            .font(.headline)
                        Text(card.imageName ?? "(nil imageName)")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .sheet(isPresented: $showDetails) {
                        DetailedCardView(card: card)
                    }
                }
            }
        } else {
            Rectangle()
                .stroke(.white, lineWidth: 2)
                .frame(width: IconSizes.getIconSize(zone: .potion), height: IconSizes.getIconSize(zone: .potion))
        }
    }
}

struct HandZoneView: View {
    @EnvironmentObject var gameEngine: GameEngine
    @State var index: Int
    @State private var showDetails: Bool = false
    
    var player: PlayerSide
    
    var body: some View {
        if gameEngine.board.getHand(owner: player).count > index {
            if let card = PresentedCardModel.cardByCode[gameEngine.board.getHand(owner: player)[index]] {
                HStack {
                    Menu {
                        Button("View Details") {
                            showDetails = true
                        }
                        if (gameEngine.activePlayer == .player) {
                            if canLegallyPlayCard(card.type) {
                                Button("Play") {
                                    gameEngine.playCard(fromHandIndex: index,owner: .player, to: CardZone.zoneForCard(card.type), hand: &gameEngine.board.playerHand)
                                }
                            }
                        }
                    } label: {
                        if let uiImage = card.iconUIImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .sheet(isPresented: $showDetails) {
                                    DetailedCardView(card: card)
                                }
                        } else {
                            VStack(spacing: 8) {
                                Text("Missing image")
                                    .font(.headline)
                                Text(card.imageName ?? "(nil imageName)")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .sheet(isPresented: $showDetails) {
                                DetailedCardView(card: card)
                            }
                        }
                        
                    }
                    Text("\(card.cardCode)")
                        .font(.custom("InknutAntiqua-Regular", size: 10))
                }
                
            }
        } else {
            HStack {
                Rectangle()
                    .stroke(.white, lineWidth: 2)
                    .frame(width: 40, height: 40)
                Text("---")
            }
            
        }
    }
    
    func canLegallyPlayCard(_ type: CardType) -> Bool {
        if gameEngine.board.previousPlayerIsAttacking && (type == .ward || type == .counterspell) && gameEngine.phase == .defend {
            return true
        }
        if (type == .curse || type == .jinx) && gameEngine.phase == .attack && gameEngine.noAbilitiesOnStack {
            return true
        }
        if (type == .charm || type == .relic || type == .potion) && gameEngine.phase == .action && gameEngine.noAbilitiesOnStack {
            return true
        }
        return false
    }
}

