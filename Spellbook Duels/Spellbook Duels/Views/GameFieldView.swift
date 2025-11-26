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
    var body: some View {
        VStack {
            Image(systemName: "book")
                .font(.system(size: 100))
                .fontWeight(.thin)
                .foregroundStyle(.white)
            
            HStack(spacing: 24) {
                Rectangle()
                    .stroke(.black, lineWidth: 2)
                    .frame(width: 60, height: 60)
                Rectangle()
                    .stroke(.black, lineWidth: 2)
                    .frame(width: 60, height: 60)
                Rectangle()
                    .stroke(.black, lineWidth: 2)
                    .frame(width: 60, height: 60)
            }
            
            HStack(spacing: 19) {
                Rectangle()
                    .stroke(.black, lineWidth: 2)
                    .frame(width: 60, height: 60)
                Rectangle()
                    .stroke(.black, lineWidth: 2)
                    .frame(width: 80, height: 80)
                    .padding(.top, 11)
                Rectangle()
                    .stroke(.black, lineWidth: 2)
                    .frame(width: 60, height: 60)
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
    var body: some View {
        VStack {
            HStack {
                Rectangle() // Discard Pile
                    .fill(.black.opacity(0.5))
                    .frame(width: 80, height: 80)
                Spacer()
//                Rectangle() // Spellbook
//                    .fill(Color("AccentOne"))
//                    .frame(width: 80, height: 80)
            }
            
            HStack(spacing: 19) {
                Rectangle()
                    .stroke(.black, lineWidth: 2)
                    .frame(width: 60, height: 60)
                Rectangle()
                    .stroke(.black, lineWidth: 2)
                    .frame(width: 80, height: 80)
                    .padding(.top, 11)
                Rectangle()
                    .stroke(.black, lineWidth: 2)
                    .frame(width: 60, height: 60)
            }
            
            HStack(spacing: 24) {
                Rectangle()
                    .stroke(.black, lineWidth: 2)
                    .frame(width: 60, height: 60)
                Rectangle()
                    .stroke(.black, lineWidth: 2)
                    .frame(width: 60, height: 60)
                Rectangle()
                    .stroke(.black, lineWidth: 2)
                    .frame(width: 60, height: 60)
            }
            Image(systemName: "book")
                .font(.system(size: 100))
                .fontWeight(.thin)
                .foregroundStyle(.white)
        }
        .padding(.top, 0)
    }
}

#Preview {
    GameFieldView()
        .environmentObject(ViewController())
}
