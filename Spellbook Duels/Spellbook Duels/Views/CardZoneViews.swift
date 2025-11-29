//
//  CardZoneViews.swift
//  Spellbook Duels
//
//  Created by Rocky Williams on 11/28/25.
//

import SwiftUI

struct CurseCardView: View {
    @State var cardCode: String
    @State private var showDetails: Bool = false
    
    var body: some View {
        if let card = PresentedCardModel.cardByCode[cardCode] {
            Menu {
                Button("View Details") {
                    showDetails = true
                }
                Button("Activate") {
                    
                }
            } label: {
                if let image = card.icon {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .sheet(isPresented: $showDetails) {
                            DetailedCardView(card: card)
                        }
                } else {
                    Image("MenuBackgroundColor")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .sheet(isPresented: $showDetails) {
                            DetailedCardView(card: card)
                        }
                }
            }
        } else {
            Rectangle()
                .stroke(.white, lineWidth: 2)
                .frame(width: 60, height: 60)
        }
    }
}

struct SnapCardView: View {
    @State var cardCode: String
    @State private var showDetails: Bool = false
    
    var body: some View {
        if let card = PresentedCardModel.cardByCode[cardCode] {
            Menu {
                Button("View Details") {
                    showDetails = true
                }
                Button("Activate") {
                    
                }
            } label: {
                if let image = card.icon {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .sheet(isPresented: $showDetails) {
                            DetailedCardView(card: card)
                        }
                } else {
                    Image("MenuBackgroundColor")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .sheet(isPresented: $showDetails) {
                            DetailedCardView(card: card)
                        }
                }
            }
        } else {
            Rectangle()
                .stroke(.white, lineWidth: 2)
                .frame(width: 80, height: 80)
        }
    }
}

struct WardCardView: View {
    @State var cardCode: String
    @State private var showDetails: Bool = false
    
    var body: some View {
        if let card = PresentedCardModel.cardByCode[cardCode] {
            Menu {
                Button("View Details") {
                    showDetails = true
                }
                Button("Activate") {
                    
                }
            } label: {
                if let image = card.icon {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .sheet(isPresented: $showDetails) {
                            DetailedCardView(card: card)
                        }
                } else {
                    Image("MenuBackgroundColor")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .sheet(isPresented: $showDetails) {
                            DetailedCardView(card: card)
                        }
                }
            }
        } else {
            Rectangle()
                .stroke(.white, lineWidth: 2)
                .frame(width: 60, height: 60)
        }
    }
}

struct CharmCardView: View {
    @State var cardCode: String
    @State private var showDetails: Bool = false
    
    var body: some View {
        if let card = PresentedCardModel.cardByCode[cardCode] {
            Menu {
                Button("View Details") {
                    showDetails = true
                }
                Button("Activate") {
                    
                }
            } label: {
                if let image = card.icon {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .sheet(isPresented: $showDetails) {
                            DetailedCardView(card: card)
                        }
                } else {
                    Image("MenuBackgroundColor")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .sheet(isPresented: $showDetails) {
                            DetailedCardView(card: card)
                        }
                }
            }
        } else {
            Rectangle()
                .stroke(.white, lineWidth: 2)
                .frame(width: 60, height: 60)
        }
    }
}

struct RelicCardView: View {
    @State var cardCode: String
    @State private var showDetails: Bool = false
    
    var body: some View {
        if let card = PresentedCardModel.cardByCode[cardCode] {
            Menu {
                Button("View Details") {
                    showDetails = true
                }
                Button("Activate") {
                    
                }
            } label: {
                if let image = card.icon {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .sheet(isPresented: $showDetails) {
                            DetailedCardView(card: card)
                        }
                } else {
                    Image("MenuBackgroundColor")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .sheet(isPresented: $showDetails) {
                            DetailedCardView(card: card)
                        }
                }
            }
        } else {
            Rectangle()
                .stroke(.white, lineWidth: 2)
                .frame(width: 60, height: 60)
        }
    }
}

struct PotionCardView: View {
    @State var cardCode: String
    @State private var showDetails: Bool = false
    
    var body: some View {
        if let card = PresentedCardModel.cardByCode[cardCode] {
            Menu {
                Button("View Details") {
                    showDetails = true
                }
                Button("Activate") {
                    
                }
            } label: {
                if let image = card.icon {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .sheet(isPresented: $showDetails) {
                            DetailedCardView(card: card)
                        }
                } else {
                    Image("MenuBackgroundColor")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .sheet(isPresented: $showDetails) {
                            DetailedCardView(card: card)
                        }
                }
            }
        } else {
            Rectangle()
                .stroke(.white, lineWidth: 2)
                .frame(width: 60, height: 60)
        }
    }
}

struct HandZoneView: View {
    @EnvironmentObject var gameEngine: GameEngine
    @State var cardCode: String
    @State private var showDetails: Bool = false
    
    var body: some View {
        if let card = PresentedCardModel.cardByCode[cardCode] {
            HStack {
                Menu {
                    Button("View Details") {
                        showDetails = true
                    }
                    if (gameEngine.activePlayer == .player) {
                        if (gameEngine.phase == .defend && card.type == .ward) {
                            Button("Play") {
                                if gameEngine.board.playerWard.card == "" {
                                    gameEngine.board.playerWard.card = cardCode
                                } else {
                                    
                                }
                            }
                        } else if (gameEngine.phase == .action && (card.type != .curse || card.type != .counterspell)) {
                            Button("Play") {
                                
                            }
                        } else if (gameEngine.phase == .attack && (card.type == .curse || card.type == .counterspell) ) {
                            Button("Play") {
                                
                            }
                        }
                    }
                    
                } label: {
                    if let image = card.icon {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .sheet(isPresented: $showDetails) {
                                DetailedCardView(card: card)
                            }
                    } else {
                        Image("MenuBackgroundColor")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .sheet(isPresented: $showDetails) {
                                DetailedCardView(card: card)
                            }
                    }
                    
                }
                Text("\(card.cardCode)")
                    .font(.custom("InknutAntiqua-Regular", size: 10))
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
}

