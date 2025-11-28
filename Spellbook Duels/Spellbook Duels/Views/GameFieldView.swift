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
                    VStack {
                        HandZoneView(cardCode: "EAS")
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
