//
//  DetailedCardView.swift
//  Spellbook Duels
//
//  Created by Rocky Williams on 11/29/25.
//

import SwiftUI

struct DetailedCardView: View {
    let card: PresentedCardModel
    
    var body: some View {
        ZStack {
            Color("AccentOne")
                .ignoresSafeArea()
            if let uiImage = card.uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                VStack(spacing: 8) {
                    Text("Missing image")
                        .font(.headline)
                    Text(card.imageName ?? "(nil imageName)")
                        .font(.caption)
                }
                .foregroundColor(.white)
                .padding()
            }
        }
    }
}

struct CardPopupModifier<PopupContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let popupContent: () -> PopupContent

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                // Dimmed background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isPresented = false
                        }
                    }

                // Popup content
                popupContent()
//                    .padding()
//                    .background(.white)
//                    .cornerRadius(20)
//                    .shadow(radius: 20)
//                    .transition(.scale.combined(with: .opacity))
//                    .zIndex(1)
            }
        }
        .animation(.easeInOut, value: isPresented)
    }
}

extension View {
    func cardPopup<PopupContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> PopupContent
    ) -> some View {
        self.modifier(CardPopupModifier(isPresented: isPresented,
                                    popupContent: content))
    }
}
