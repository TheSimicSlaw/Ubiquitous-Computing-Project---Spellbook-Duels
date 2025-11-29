//
//  GameFieldView.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 10/3/25.
//

import SwiftUI

struct GameFieldView: View {
    @EnvironmentObject var viewController: ViewController
    
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
                Rectangle() // Discard Pile
                    .fill(.black.opacity(0.5))
                    .frame(width: 80, height: 80)
                Spacer()
                if (viewController.board.turn == .opponent) {
                    OpponentPhaseView(phase: viewController.board.opponentPhase)
                    Spacer()
                }
                Text("\(viewController.board.opponentAetherTotal) Ae")
                    .font(.custom("InknutAntiqua-Regular", size: 20))
                    .foregroundStyle(.white)
                    .padding(.trailing)
            }
        }
        
    }
}

struct PlayerFieldView: View {
    @EnvironmentObject var viewController: ViewController
    //@State private var isShowing = false
    var body: some View {
        VStack() {
            HStack {
                Rectangle() // Discard Pile
                    .fill(.black.opacity(0.5))
                    .frame(width: 80, height: 80)
                Spacer()
                if (viewController.board.turn == .player) {
                    PlayerPhaseView()
                    Spacer()
                }
                
                Text("\(viewController.board.opponentAetherTotal) Ae")
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
                        HandZoneView(cardCode: viewController.board.playerHand[0])
                        HandZoneView(cardCode: viewController.board.playerHand[1])
                        HandZoneView(cardCode: viewController.board.playerHand[2])
//                        Rectangle()
//                            .stroke(.white, lineWidth: 2)
//                            .frame(width: 40, height: 40)
//                        Rectangle()
//                            .stroke(.white, lineWidth: 2)
//                            .frame(width: 40, height: 40)
                    }
                    VStack(spacing: 10) {
                        HandZoneView(cardCode: viewController.board.playerHand[3])
                        HandZoneView(cardCode: viewController.board.playerHand[4])
                        HandZoneView(cardCode: viewController.board.playerHand[5])
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
    @State private var phase: String = "DP"
    var body: some View {
        Menu {
            if (viewController.board.playerPhase < GamePhase.replenish) {
                Button("Replenish Phase") {
                    viewController.board.playerPhase = .replenish
                    phase = "RP"
                }
            }
            if (viewController.board.playerPhase < GamePhase.action) {
                Button("Action Phase") {
                    viewController.board.playerPhase = .action
                    phase = "ACP"
                }
            }
            if (viewController.board.playerPhase < GamePhase.attack) {
                Button("Attack Phase") {
                    viewController.board.playerPhase = .attack
                    phase = "ATP"
                }
            }
            
            Button("End Turn") {
                viewController.board.playerPhase = .defend
                viewController.board.turn = .opponent
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
    @State var phase: GamePhase
    
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

#Preview {
    GameFieldView()
        .environmentObject(ViewController())
}
