//
//  LoadingGameView.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 10/3/25.
//

import SwiftUI

struct LoadingGameView: View {
    var body: some View {
        ZStack {
            Color.accentOne
                .ignoresSafeArea()
            Text("Loading...")
                .font(.custom("InknutAntiqua-Light", size: 25))
        }
    }
}

#Preview {
    LoadingGameView()
}
