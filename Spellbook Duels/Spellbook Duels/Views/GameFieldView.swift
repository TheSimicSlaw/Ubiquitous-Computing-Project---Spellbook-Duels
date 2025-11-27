//
//  GameFieldView.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 10/3/25.
//

import SwiftUI

struct GameFieldView: View {
    @EnvironmentObject var viewController: ViewController
    var body: some View {
        ZStack {
            FieldBackgroundView()
            VStack(spacing: 0) {
                OpponentFieldView()
//                RoundedRectangle(cornerRadius: 40)
//                    .frame(height: 20)

                Divider()
                    .frame(height: 2)
                    .overlay(Color.black)
                PlayerFieldView()
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
                .ignoresSafeArea()
        }
    }
}

struct OpponentFieldView: View {
    @EnvironmentObject var viewController: ViewController
    
    var body: some View {
        VStack {
            HStack {
                Text("\(viewController.board.opponentAetherTotal) Ae")
                    .font(.custom("InknutAntiqua-Regular", size: 30))
                    .padding(.top)
                Spacer()
            }
            .padding()
//            Image(systemName: "book")
//                .font(.system(size: 100))
//                .fontWeight(.thin)
//                .foregroundStyle(.white)
            
            HStack(spacing: 24) { // Opponent's Potion, Relic, and Charm Zones
                if viewController.board.opponentPotion.card != "" {
                    
                } else {
                    Rectangle()
                        .stroke(.black, lineWidth: 2)
                        .frame(width: 60, height: 60)
                    
                }
                if viewController.board.opponentRelic.card != "" {
                    
                } else {
                    Rectangle()
                        .stroke(.black, lineWidth: 2)
                        .frame(width: 60, height: 60)
                }
                if viewController.board.opponentCharm.card != "" {
                    
                } else {
                    Rectangle()
                        .stroke(.black, lineWidth: 2)
                        .frame(width: 60, height: 60)
                }
            }
            
            HStack(spacing: 19) { // Opponent's Ward, Snap, and Curse zones
                if viewController.board.opponentWard.card != "" {
                    
                } else {
                    Rectangle()
                        .stroke(.black, lineWidth: 2)
                        .frame(width: 60, height: 60)
                    
                }
                if viewController.board.opponentSnap.card != "" {
                    
                } else {
                    Rectangle()
                        .stroke(.black, lineWidth: 2)
                        .frame(width: 80, height: 80)
                        .padding(.top, 11)
                }
                if viewController.board.opponentCurse.card != "" {
                    
                } else {
                    Rectangle()
                        .stroke(.black, lineWidth: 2)
                        .frame(width: 60, height: 60)
                }
            }
            
            HStack {
                Rectangle() // Discard Pile
                    .fill(.black.opacity(0.5))
                    .frame(width: 80, height: 80)
                Spacer()
//                Rectangle() // Spellbook
//                    .fill(Color("AccentOne"))
//                    .frame(width: 80, height: 80)
            }
        }
        
    }
}

struct PlayerFieldView: View {
    @EnvironmentObject var viewController: ViewController
    var body: some View {
        VStack() {
            HStack {
                Rectangle() // Discard Pile
                    .fill(.black.opacity(0.5))
                    .frame(width: 80, height: 80)
                Spacer()
//                Rectangle() // Spellbook
//                    .fill(Color("AccentOne"))
//                    .frame(width: 80, height: 80)
            }
            
            HStack(spacing: 19) { // Player's Curse, Snap, and Ward Zone
                if viewController.board.playerCurse.card != "" {
                    
                } else {
                    Rectangle()
                        .stroke(.black, lineWidth: 2)
                        .frame(width: 60, height: 60)
                    
                }
                if viewController.board.playerSnap.card != "" {
                    
                } else {
                    Rectangle()
                        .stroke(.black, lineWidth: 2)
                        .frame(width: 80, height: 80)
                        .padding(.top, 11)
                }
                if viewController.board.playerWard.card != "" {
                    
                } else {
                    Rectangle()
                        .stroke(.black, lineWidth: 2)
                        .frame(width: 60, height: 60)
                }
                
            }
            
            HStack(spacing: 24) { // Player's Player's Charm, Relic, and Potion Zone
                if viewController.board.playerCharm.card != "" {
                    
                } else {
                    Rectangle()
                        .stroke(.black, lineWidth: 2)
                        .frame(width: 60, height: 60)
                    
                }
                if viewController.board.playerRelic.card != "" {
                    
                } else {
                    Rectangle()
                        .stroke(.black, lineWidth: 2)
                        .frame(width: 60, height: 60)
                }
                if viewController.board.playerPotion.card != "" {
                    
                } else {
                    Rectangle()
                        .stroke(.black, lineWidth: 2)
                        .frame(width: 60, height: 60)
                }
            }
            
            HStack {
                Text("\(viewController.board.opponentAetherTotal) Ae")
                    .font(.custom("InknutAntiqua-Regular", size: 30))
                    .padding(.top)
                Spacer()
                
            }
            .padding()
        }
        .padding(.top, 0)
    }
}

#Preview {
    GameFieldView()
        .environmentObject(ViewController())
}
