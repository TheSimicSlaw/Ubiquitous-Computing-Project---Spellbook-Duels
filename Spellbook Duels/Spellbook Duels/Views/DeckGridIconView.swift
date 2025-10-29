//
//  DeckGridIconView.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 10/29/25.
//

import SwiftUI

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
