//
//  GameFieldView.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 10/3/25.
//

import SwiftUI

struct GameFieldView: View {
    @EnvironmentObject var viewController: ViewController
    @EnvironmentObject var gameEngine: GameEngine
    
    @State private var showHandLimitPopup = false
    @State private var showHandLimitSheet = false
    
    @State var isAskingToTurnPage: Bool = false
    
    var body: some View {
        ZStack {
            FieldBackgroundView()
            
            VStack(spacing: 0) {
                OpponentFieldView()
                
                Divider()
                    .frame(height: 2)
                    .overlay(Color.black)
                
                PlayerFieldView()
            }
        }
        .onChange(of: gameEngine.isAskingToDiscardForHandLimit) { needed in
            if needed {
                showHandLimitPopup = true
            }
        }
        .alert("Hand Limit Exceeded",
               isPresented: $showHandLimitPopup) {
            Button("Continue") {
                showHandLimitPopup = false
                showHandLimitSheet = true
            }
        } message: {
            Text("You have too many cards in your hand. Discard until you only have 6 cards.")
        }
        .sheet(isPresented: $showHandLimitSheet) {
            handLimitSheetContent()
        }
    }
    
    // MARK: Popups
    
    private var askingToTurnPagePopupContent: some View {
        GeometryReader { geo in
            let maxWidth = min(geo.size.width * 0.8, 380)
            
            
            VStack(spacing:12) {
                
                //.padding(.top, 8)
            }
            .frame(width: maxWidth)
            .padding(.vertical, 16)
            .frame(
                width: geo.size.width,
                height: geo.size.height,
                alignment: .center
            )
        }
        .frame(height: 260)
    }
    
    @ViewBuilder
    private func handLimitSheetContent() -> some View {
        if let owner = gameEngine.pendingHandLimitOwner {
            let cards = gameEngine.pendingHandLimitCards
            let numExcessCards = cards.count - 6
                
            SelectCardsView(cards: cards, numCardsToSelect: numExcessCards) { cardsToDiscard, _ in
                    // Start with original hand
                var hand = cards
                    // Use your helper to move selected cards to discard
                gameEngine.cardsToDiscard(cardsToDiscard, from: &hand, player: owner)
                // Update hand on the board
                gameEngine.board.setHand(hand, owner: owner)
                    
                    // Clear engine state
                gameEngine.pendingHandLimitCards = []
                gameEngine.pendingHandLimitOwner = nil
                gameEngine.isAskingToDiscardForHandLimit = false
            }
        }
    }
    
}

struct FieldBackgroundView: View {
    var body: some View {
            GeometryReader { geo in
                Image("gamefieldbg")
                    .resizable()
                    .scaledToFill()
                    .rotationEffect(Angle(degrees: 90))
                    .frame(width: geo.size.width, height: geo.size.height)
            }
    }
}

struct OpponentFieldView: View {
    @EnvironmentObject var viewController: ViewController
    @EnvironmentObject var gameEngine: GameEngine
    @EnvironmentObject var firebaseController: DatabaseController
    
    var body: some View {
        VStack {
            Spacer(minLength: 7)
            HStack {
                Spacer(minLength: 20)
                Menu {
                    Button("Concede") {
                        viewController.inGame = false
                        firebaseController.endMatch(matchCode: viewController.matchCode)
                        viewController.matchCode = ""
                        firebaseController.opponent = Player()
                    }
                } label: {
                    Image(systemName: "flag.fill")
                        .foregroundStyle(.white)
                        .font(Font.system(size: 30))
                        .padding()
                    Spacer()
                }
            }
            
            HStack(spacing: 29) { // Opponent's Potion, Relic, and Charm Zones
                PotionCardView(player: .opponent)
                    .shadow(color: .yellow, radius: 10)
                    .shadow(color: .yellow, radius: 10)
                    .shadow(color: .yellow, radius: 15)
                CharmCardView(player: .opponent)
                RelicCardView(player: .opponent)
            }
            
            HStack(spacing: 19) { // Opponent's Ward, Snap, and Curse zones
                WardCardView(player: .opponent)
                SnapCardView(player: .opponent)
                CurseCardView(player: .opponent)
            }
            
            HStack {
                DiscardPileView(discardPile: gameEngine.board.opponentDiscard)

                Spacer()
                if (gameEngine.activePlayer == .opponent) {
                    OpponentPhaseView(phase: gameEngine.phase)
                    Spacer()
                }
                Text("\(gameEngine.board.opponentAetherTotal) Ae")
                    .font(.custom("InknutAntiqua-Regular", size: 20))
                    .foregroundStyle(.white)
                    .padding(.trailing)
            }
        }
        
    }
}

struct PlayerFieldView: View {
    @EnvironmentObject var viewController: ViewController
    @EnvironmentObject var gameEngine: GameEngine
    //@State private var isShowing = false
    var body: some View {
        VStack() {
            HStack(spacing: 2) {
                DiscardPileView(discardPile: gameEngine.board.playerDiscard)
                                
                Spacer()
                
                if (gameEngine.activePlayer == .player) {
                    PlayerPhaseView()
                    Spacer()
                }
                
                Text("\(gameEngine.board.opponentAetherTotal) Ae")
                    .font(.custom("InknutAntiqua-Regular", size: 20))
                    .foregroundStyle(.white)
                    .padding(.trailing)
            }
            
            HStack(spacing: 19) { // Player's Curse, Snap, and Ward Zone
                CurseCardView(player: .player)
                SnapCardView(player: .player)
                WardCardView(player: .player)
                
            }
            
            HStack(spacing: 29) { // Player's Player's Charm, Relic, and Potion Zone
                RelicCardView(player: .player)
                CharmCardView(player: .player)
                PotionCardView(player: .player)
            }
            .padding(.bottom, 30)
            
            
            HStack {
                ZStack {
                    Image("spellbook")
                        .resizable()
                        .scaledToFill()
                    HStack(spacing: 80) {
                        VStack(spacing: 10) {
                            HandZoneView(index: 0, player: .player)
                            HandZoneView(index: 1, player: .player)
                            HandZoneView(index: 2, player: .player)
                        }
                        VStack(spacing: 10) {
                            HandZoneView(index: 3, player: .player)
                            HandZoneView(index: 4, player: .player)
                            HandZoneView(index: 5, player: .player)
                        }
                    }
                }
                .frame(width: 264, height: 157)
                PlayerDeckView(activateScryingWater: true, activateSeersScryingBowl: true)

            }
            
            Spacer(minLength: 36)
            
        }
        .padding(.top, 0)
    }
}

struct PlayerPhaseView: View {
    @EnvironmentObject var viewController: ViewController
    @EnvironmentObject var gameEngine: GameEngine
    @State private var phase: String = "DP" 
    var body: some View {
        Menu {
            if (gameEngine.phase < Phase.replenish) {
                Button("Replenish Phase") {
                    gameEngine.phase = .replenish
                    phase = "RP"
                }
            }
            if (gameEngine.phase < Phase.action) {
                Button("Action Phase") {
                    gameEngine.phase = .action
                    phase = "ACP"
                }
            }
            if (gameEngine.phase < Phase.attack) {
                Button("Attack Phase") {
                    gameEngine.phase = .attack
                    phase = "ATP"
                }
            }
            if (gameEngine.phase == .replenish) {
                Button("Turn The Page") {
                    gameEngine.isAskingToTurnPage = true
                }
            }
            
            Button("End Turn") {
                gameEngine.phase = .defend
                gameEngine.activePlayer = .opponent
                gameEngine.isAskingToTurnPage = false
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.accentOne)
                    .frame(width: 75, height: 30)
                Text("Pass Phase")
                    .font(.custom("InknutAntiqua-Regular", size: 10))
                    .foregroundStyle(.black)
            }
        }
    }
}

struct OpponentPhaseView: View {
    @State var phase: Phase
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.red)
                .frame(width: 50, height: 30)
            
            if (phase == .defend) {
                Text("DP")
                    .font(.custom("InknutAntiqua-Regular", size: 10))
                    .foregroundStyle(.white)
            } else if (phase == .replenish) {
                Text("RP")
                    .font(.custom("InknutAntiqua-Regular", size: 10))
                    .foregroundStyle(.white)
            } else if (phase == .action) {
                Text("ACP")
                    .font(.custom("InknutAntiqua-Regular", size: 10))
                    .foregroundStyle(.white)
            } else if (phase == .attack) {
                Text("ATP")
                    .font(.custom("InknutAntiqua-Regular", size: 10))
                    .foregroundStyle(.white)
            }
        }
        
    }
}

struct DiscardPileView: View {
    //@EnvironmentObject var gameEngine: GameEngine
    
    @State var discardPile: [String]
    var body: some View {
        if (discardPile.isEmpty) {
            Rectangle() // Discard Pile
                .fill(.black.opacity(0.5))
                .frame(width: 60, height: 60)
        } else {
            let cardCode = discardPile[discardPile.count - 1]
            if let card = PresentedCardModel.cardByCode[cardCode] {
                if let uiImage = card.iconUIImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .opacity(0.5)
                } else {
                    VStack(spacing: 8) {
                        Text("Missing image")
                            .font(.headline)
                        Text(card.imageName ?? "(nil imageName)")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding()
                }
            }
        }
    }
}

#Preview {
    GameFieldView()
        .environmentObject(ViewController())
        .environmentObject(GameEngine())
}
