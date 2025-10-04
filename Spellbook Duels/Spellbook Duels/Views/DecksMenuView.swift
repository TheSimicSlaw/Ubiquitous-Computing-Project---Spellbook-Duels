//
//  DecksMenuView.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 10/3/25.
//

import SwiftUI

struct DecksMenuView: View {
    var body: some View {
        ZStack {
            
            Color("MenuBackgroundColor")
                .ignoresSafeArea()
            
            VStack{
                Image(systemName: "book.closed.fill") // Hopefully this can work as a deck label?
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 150)
                    .padding(.horizontal, 10)
                    .padding(.top, 10)
                    .foregroundStyle(LinearGradient(
                        gradient: Gradient(colors: [.red, .blue]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                
                Text("Fire And Water")
                    .font(.custom( "InknutAntiqua-Regular", size: 19.0))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(10)
            }
            .frame(width: 200, height: .infinity)
            .background(Color("AccentOne"))
        }
        
    }
}

#Preview {
    DecksMenuView()
}
