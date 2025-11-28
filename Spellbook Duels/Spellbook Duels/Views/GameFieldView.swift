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
                //.ignoresSafeArea()
            }
    }
}

struct OpponentFieldView: View {
    @EnvironmentObject var viewController: ViewController
    
    var body: some View {
        VStack {
            HStack {
                
                Spacer()
            }
            .padding()
            
            HStack(spacing: 24) { // Opponent's Potion, Relic, and Charm Zones
                if viewController.board.opponentPotion.card != "" {
                    
                } else {
                    Rectangle()
                        .stroke(.white, lineWidth: 2)
                        .frame(width: 60, height: 60)
                    
                }
                if viewController.board.opponentRelic.card != "" {
                    
                } else {
                    Rectangle()
                        .stroke(.white, lineWidth: 2)
                        .frame(width: 60, height: 60)
                }
                if viewController.board.opponentCharm.card != "" {
                    
                } else {
                    Rectangle()
                        .stroke(.white, lineWidth: 2)
                        .frame(width: 60, height: 60)
                }
            }
            
            HStack(spacing: 19) { // Opponent's Ward, Snap, and Curse zones
                if viewController.board.opponentWard.card != "" {
                    
                } else {
                    Rectangle()
                        .stroke(.white, lineWidth: 2)
                        .frame(width: 60, height: 60)
                    
                }
                if viewController.board.opponentSnap.card != "" {
                    
                } else {
                    Rectangle()
                        .stroke(.white, lineWidth: 2)
                        .frame(width: 80, height: 80)
                        .padding(.top, 11)
                }
                if viewController.board.opponentCurse.card != "" {
                    
                } else {
                    Rectangle()
                        .stroke(.white, lineWidth: 2)
                        .frame(width: 60, height: 60)
                }
            }
            
            HStack {
                Rectangle() // Discard Pile
                    .fill(.black.opacity(0.5))
                    .frame(width: 80, height: 80)
                Spacer()
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
    @State private var isShowing = false
    var body: some View {
        VStack() {
            HStack {
                Rectangle() // Discard Pile
                    .fill(.black.opacity(0.5))
                    .frame(width: 80, height: 80)
                Spacer()
                Text("\(viewController.board.opponentAetherTotal) Ae")
                    .font(.custom("InknutAntiqua-Regular", size: 20))
                    .foregroundStyle(.white)
                    .padding(.trailing)
            }
            
            HStack(spacing: 19) { // Player's Curse, Snap, and Ward Zone
                if viewController.board.playerCurse.card != "" {
                    
                } else {
                    Rectangle()
                        .stroke(.white, lineWidth: 2)
                        .frame(width: 60, height: 60)
                    
                }
                if viewController.board.playerSnap.card != "" {
                    
                } else {
                    Rectangle()
                        .stroke(.white, lineWidth: 2)
                        .frame(width: 80, height: 80)
                        .padding(.top, 11)
                }
                if viewController.board.playerWard.card != "" {
                    
                } else {
                    Rectangle()
                        .stroke(.white, lineWidth: 2)
                        .frame(width: 60, height: 60)
                }
                
            }
            
            HStack(spacing: 24) { // Player's Player's Charm, Relic, and Potion Zone
                if viewController.board.playerCharm.card != "" {
                    
                } else {
                    Rectangle()
                        .stroke(.white, lineWidth: 2)
                        .frame(width: 60, height: 60)
                    
                }
                if viewController.board.playerRelic.card != "" {
                    Image("testzone")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .onTapGesture(count: 2) {
                            isShowing = true
                        }
                } else {
                    Rectangle()
                        .stroke(.white, lineWidth: 2)
                        .frame(width: 60, height: 60)
                }
                if viewController.board.playerPotion.card != "" {
                    
                } else {
                    Rectangle()
                        .stroke(.white, lineWidth: 2)
                        .frame(width: 60, height: 60)
                }
            }
            .padding(.bottom)
            .sheet(isPresented: $isShowing) {
                ZStack {
                    Color("AccentOne")
                        .ignoresSafeArea()
                    Text("Detailed View")
                }
                
            }
            
            ZStack {
                Image("spellbook")
                    .resizable()
                    .scaledToFill()
                HStack(spacing: 80) {
                    VStack {
                        Rectangle()
                            .stroke(.white, lineWidth: 2)
                            .frame(width: 40, height: 40)
                        Rectangle()
                            .stroke(.white, lineWidth: 2)
                            .frame(width: 40, height: 40)
                        Rectangle()
                            .stroke(.white, lineWidth: 2)
                            .frame(width: 40, height: 40)
                    }
                    VStack {
                        Rectangle()
                            .stroke(.white, lineWidth: 2)
                            .frame(width: 40, height: 40)
                        Rectangle()
                            .stroke(.white, lineWidth: 2)
                            .frame(width: 40, height: 40)
                        Rectangle()
                            .stroke(.white, lineWidth: 2)
                            .frame(width: 40, height: 40)
                    }
                }
            }
            .frame(width: 264, height: 157)
            

            HStack {
                
                Spacer()
                
            }
            .padding()
        }
        .padding(.top, 0)
    }
}

//struct FieldCardView: View {
//    var body: some View {
//        
//    }
//}



#Preview {
    GameFieldView()
        .environmentObject(ViewController())
}
