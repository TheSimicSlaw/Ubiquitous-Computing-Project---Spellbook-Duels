//
//  GameFieldView.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 10/3/25.
//

import SwiftUI

struct GameFieldView: View {
    var body: some View {
        ZStack {
            FieldBackgroundView()
            VStack {
                OpponentFieldView()
                Spacer()
                Divider()
                    .frame(height: 2)
                    .overlay(Color.black)
                Spacer()
                PlayerFieldView()
            }
            HStack {
                Rectangle() // Discard Pile
                    .fill(.black.opacity(0.5))
                    .frame(width: 50, height: 100)
                    .padding(.trailing, 150)
                //Spacer() // <- Doesn't work as expected because the width exceeds the screen
                Rectangle() // Combined Spellbook
                    .fill(Color.accentOne)
                    .frame(width: 60, height: 100)
                    .padding(.leading, 150)
            }
        }
    }
}

struct FieldBackgroundView: View {
    var body: some View {
        Image("gamefieldbg")
            .resizable()
            .scaledToFill()
            .rotationEffect(Angle(degrees: 90))
            .ignoresSafeArea(edges: .horizontal)
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
                    .fill(.gray)
                    .frame(width: 60, height: 84)
                Rectangle()
                    .fill(.gray)
                    .frame(width: 60, height: 84)
                Rectangle()
                    .fill(.gray)
                    .frame(width: 60, height: 84)
            }
            
            HStack(spacing: 19) {
                Rectangle()
                    .fill(.gray)
                    .frame(width: 60, height: 84)
                Rectangle()
                    .fill(.gray)
                    .frame(width: 80, height: 112)
                    .padding(.top, 11)
                Rectangle()
                    .fill(.gray)
                    .frame(width: 60, height: 84)
            }
        }
        
    }
}

struct PlayerFieldView: View {
    var body: some View {
        VStack {
            HStack(spacing: 19) {
                Rectangle()
                    .fill(.gray)
                    .frame(width: 60, height: 84)
                Rectangle()
                    .fill(.gray)
                    .frame(width: 80, height: 112)
                    .padding(.top, 11)
                Rectangle()
                    .fill(.gray)
                    .frame(width: 60, height: 84)
            }
            
            HStack(spacing: 24) {
                Rectangle()
                    .fill(.gray)
                    .frame(width: 60, height: 84)
                Rectangle()
                    .fill(.gray)
                    .frame(width: 60, height: 84)
                Rectangle()
                    .fill(.gray)
                    .frame(width: 60, height: 84)
            }
            Image(systemName: "book")
                .font(.system(size: 100))
                .fontWeight(.thin)
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    GameFieldView()
}
