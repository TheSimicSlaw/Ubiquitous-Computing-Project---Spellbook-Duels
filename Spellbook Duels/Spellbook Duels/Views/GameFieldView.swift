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
        .newPopup(isPresented: $isAskingToTurnPage) {
            askingToTurnPagePopupContent
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
    
    var body: some View {
        VStack {
            HStack(spacing: 24) { // Opponent's Potion, Relic, and Charm Zones
                PotionCardView(cardCode: "")
                RelicCardView(cardCode: "")
                CharmCardView(cardCode: "")
            }
            
            HStack(spacing: 19) { // Opponent's Ward, Snap, and Curse zones
                WardCardView(cardCode: "")
                SnapCardView(cardCode: "")
                CurseCardView(cardCode: "")
            }
            
            HStack {
                DiscardPileView(discardPile: gameEngine.board.opponentDiscard)

                Spacer()
                if (gameEngine.activePlayer == .opponent) {
                    OpponentPhaseView(phase: viewController.board.phase)
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
            HStack {
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
                CurseCardView(cardCode: "")
                SnapCardView(cardCode: "")
                WardCardView(cardCode: "")
                
            }
            
            HStack(spacing: 24) { // Player's Player's Charm, Relic, and Potion Zone
                CharmCardView(cardCode: "EAS")
                RelicCardView(cardCode: "EST")
                PotionCardView(cardCode: "WIN")
            }
            .padding(.bottom)
            
            ZStack {
                Image("spellbook")
                    .resizable()
                    .scaledToFill()
                HStack(spacing: 80) {
                    VStack(spacing: 10) {
                        HandZoneView(cardCode: gameEngine.board.playerHand[0])
                        HandZoneView(cardCode: gameEngine.board.playerHand[1])
                        HandZoneView(cardCode: gameEngine.board.playerHand[2])
//                        Rectangle()
//                            .stroke(.white, lineWidth: 2)
//                            .frame(width: 40, height: 40)
//                        Rectangle()
//                            .stroke(.white, lineWidth: 2)
//                            .frame(width: 40, height: 40)
                    }
                    VStack(spacing: 10) {
                        HandZoneView(cardCode: gameEngine.board.playerHand[3])
                        HandZoneView(cardCode: gameEngine.board.playerHand[4])
                        HandZoneView(cardCode: gameEngine.board.playerHand[5])
//                        Rectangle()
//                            .stroke(.white, lineWidth: 2)
//                            .frame(width: 40, height: 40)
//                        Rectangle()
//                            .stroke(.white, lineWidth: 2)
//                            .frame(width: 40, height: 40)
//                        Rectangle()
//                            .stroke(.white, lineWidth: 2)
//                            .frame(width: 40, height: 40)
                    }
                }
            }
            .frame(width: 264, height: 157)
            

            
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
                    .foregroundStyle(.green)
                    .frame(width: 50, height: 30)
                Text("\(phase)")
                    .font(.custom("InknutAntiqua-Regular", size: 10))
                    .foregroundStyle(.white)
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
                .frame(width: 80, height: 80)
        } else {
            let cardCode = discardPile[discardPile.count - 1]
            if let card = PresentedCardModel.cardByCode[cardCode] {
                Image(uiImage: card.icon!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .opacity(0.5)
            }
        }
    }
}

#Preview {
    GameFieldView()
        .environmentObject(ViewController())
        .environmentObject(GameEngine())
}
