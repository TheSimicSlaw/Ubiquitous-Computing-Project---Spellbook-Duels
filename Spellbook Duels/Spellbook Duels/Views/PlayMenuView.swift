//
//  PlayMenuView.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 10/3/25.
//

import SwiftUI

struct PlayMenuView: View {
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    @State private var isLoading = false
    @State private var navigating = false
    
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
                NavigationStack {
                    ScrollView {
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
                    }
                    //.border(.black)
                    Button("Start Game") {
                        startLoading()
                    }
                    .frame(width: 200, height: 50)
                    .font(.custom("InknutAntiqua-Regular", size: 20))
                    .foregroundStyle(.black)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.accentOne)
                    }
                    .padding(.bottom, 20)
                    
                    // technically works, but uses an outdated method. Will need to change later
                    NavigationLink(destination: GameFieldView(),isActive: $navigating) {
                        EmptyView()
                    }
                }
            }
        }
        .overlay {
            if isLoading {
                LoadingGameView()
            }
        }
    }
    
    func startLoading() {
            isLoading = true
            // Simulate network delay or work
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isLoading = false
                navigating = true
            }
        }
}


#Preview {
    PlayMenuView()
}
