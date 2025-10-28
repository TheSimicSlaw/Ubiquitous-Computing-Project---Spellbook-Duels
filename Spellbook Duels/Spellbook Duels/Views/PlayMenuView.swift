//
//  PlayMenuView.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 10/3/25.
//

import SwiftUI

struct PlayMenuView: View {
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ZStack(alignment: .top) {
            Color("MenuBackgroundColor")
                .ignoresSafeArea()
            VStack {
                Text("Spellbook Duels")
                    .font(.custom("InknutAntiqua-Bold", size: 35.0))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .background(Color.accentTwo)
                
                LazyVGrid(columns: columns) {
                    DeckGridIconView(colors: [.blue, .red])
                    DeckGridIconView(colors: [.blue, .brown])
                    DeckGridIconView(colors: [.white, .red])
                    DeckGridIconView(colors: [.brown, .red])
                    DeckGridIconView(colors: [.blue, .white])
                    DeckGridIconView(colors: [.white, .brown])
                }
                .padding(.leading, 60)
                .padding(.trailing, 60)
                //.border(.black)
                Button("Start Game") {
                    
                }
                .frame(width: 200, height: 50)
                .font(.custom("InknutAntiqua-Regular", size: 20))
                .foregroundStyle(.black)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.accentOne)
                }
                
            }
        }
    }
}

struct DeckGridIconView: View {
    let colors: [Color]
    
    var body: some View {
        Image(systemName: "book.closed.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: 110)
            .foregroundStyle(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
            .padding(.bottom)
    }
}
#Preview {
    PlayMenuView()
}
