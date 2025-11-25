//
//  NewDeckPopupView.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 11/9/25.
//

import SwiftUI

struct PopupView<PopupContent>: ViewModifier where PopupContent: View {
    
    init(isPresented: Binding<Bool>, view: @escaping () -> PopupContent) {
        self._isPresented = isPresented
        self.view = view
    }
    
    @Binding var isPresented: Bool
    
    var view: () -> PopupContent
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(1)
                
                VStack {
                    view()
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black)
                )
                .shadow(radius: 10)
                .frame(maxWidth: 350)
                .transition(.scale.combined(with: .opacity))
                .zIndex(2)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isPresented)
    }
}

extension View {
    public func newPopup<PopupContent: View>(
        isPresented: Binding<Bool>,
        view: @escaping () -> PopupContent
    ) -> some View {
        self.modifier(
            PopupView(isPresented: isPresented, view: view)
        )
    }
}

// MARK: Preview

struct DeckPopupDemo: View {
    @State private var showPopup = true

    var body: some View {
        ZStack {
            Color("MenuBackgroundColor").ignoresSafeArea()
            Text("Decks screen underneath")
                .font(.title)
                .foregroundStyle(.white)
        }
        .newPopup(isPresented: $showPopup) {
//            VStack(spacing: 12) {
//                Text("Exit?")
//                    .foregroundStyle(Color("AccentOne"))
//                    .font(.custom("InknutAntiqua-Regular", size: 24))
//                    .bold()
//
//                HStack {
//                    Button {
//                        Task {
//                            do {
//                                showPopup = false
//                                try await Task.sleep(for: .seconds(3))
//                                showPopup = true
//                            }
//                        }
//                    } label: {
//                        Text("Cancel").foregroundStyle(Color("AccentOne"))
//                            .font(.custom("InknutAntiqua-Regular", size: 18))
//                    }
//
//                    Spacer()
//
//                    Button {
//                        Task {
//                            do {
//                                showPopup = false
//                                try await Task.sleep(for: .seconds(1))
//                                showPopup = true
//                            }
//                        }
//                    } label: {
//                        Text("Exit").foregroundStyle(Color("AccentOne"))
//                            .font(.custom("InknutAntiqua-Regular", size: 18))
//                    }
//                }
//                .padding(.top, 8)
//            }
            
            
            
            GeometryReader { geo in
                let maxWidth = min(geo.size.width * 0.8, 380)
                let valid: Bool = false
                
                VStack (spacing: 12){
                    Text(valid ? "Save deck and leave?" : "This deck is invalid.\nAre you sure you want to save and leave?")
                        .foregroundStyle(Color("AccentOne"))
                        .font(.custom("InknutAntiqua-Bold", size: 18))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: maxWidth)
                    
                    HStack {
                        Button {
                            Task {
                                do {
                                    showPopup = false
                                    try await Task.sleep(for: .seconds(3))
                                    showPopup = true
                                }
                            }
                        } label: {
                            Text("Cancel")
                                .foregroundStyle(.red)
                                .font(.custom("InknutAntiqua-Regular", size: 18))
                        }

                        Spacer()

                        Button {
                            Task {
                                do {
                                    showPopup = false
                                    try await Task.sleep(for: .seconds(1))
                                    showPopup = true
                                }
                            }
                        } label: {
                            Text("Save & Leave")
                                .foregroundStyle(Color("AccentOne"))
                                .font(.custom("InknutAntiqua-Regular", size: 18))
                        }
                    }
                    .padding(.horizontal, 12)
                }
            }
            .frame(height: false ? 105 : 200)
            
            
//            VStack{
//                Text("The deck failed to save.")
//                    .foregroundStyle(Color("AccentOne"))
//                    .font(.custom("InknutAntiqua-Bold", size: 18))
//                    .multilineTextAlignment(.center)
//                
//                Button {
//                    
//                } label: {
//                    Text("Close")
//                        .foregroundStyle(.red)
//                        .font(.custom("InknutAntiqua-Light", size: 16))
//                }
//            }
            
//            GeometryReader { geo in
//                let maxWidth = min(geo.size.width * 0.8, 380)
//                let elementDiamondHeight = geo.size.height * 0.35
//                
//                
//                VStack(spacing:12) {
//                    Text("New Deck")
//                        .foregroundStyle(Color("AccentOne"))
//                        .font(.custom("InknutAntiqua-Bold", size: 24))
//                    
//                    elementButtonDiamond(height: elementDiamondHeight)
//                        .padding(.bottom, 8)
//                    
//                    TextField("Deck Name", text: .constant("Preview Deck"))
//                        .textFieldStyle(.roundedBorder)
//                        .padding(.horizontal, 8)
//                    
//                    HStack {
//                        Button {
//                            showPopup = false
//                        } label: {
//                            Text("Cancel").foregroundStyle(Color("AccentOne"))
//                                .font(.custom("InknutAntiqua-Regular", size: 18))
//                        }
//
//                        Spacer()
//
//                        Button {
//                            Task { // filler ability
//                                do {
//                                    showPopup = false
//                                    try await Task.sleep(for: .seconds(1))
//                                    showPopup = true
//                                }
//                            }
//                        } label: {
//                            Text("Create").foregroundStyle(Color("AccentOne"))
//                                .font(.custom("InknutAntiqua-Regular", size: 18))
//                        }
//                    }
//                    //.padding(.top, 8)
//                }
//                .frame(width: maxWidth)
//                .padding(.vertical, 16)
//                .frame(
//                    width: geo.size.width,
//                    height: geo.size.height,
//                    alignment: .center
//                )
//            }
//            .frame(height: 260)
        }
    }
    
    private func elementButtonDiamond(height: CGFloat) -> some View {
        GeometryReader { geo in
            let size = min(geo.size.width, height)
            let centerX = size / 2
            let centerY = size / 2
            
            ZStack {
                elementButton(.FIRE, isOn: true)
                    .position(x: centerX, y: centerY - size * 0.35)
                
                elementButton(.EARTH, isOn: false)
                    .position(x: centerX - size * 0.35, y: centerY)
                
                elementButton(.AIR, isOn: true)
                    .position(x: centerX + size * 0.35, y: centerY)
                
                elementButton(.WATER, isOn: false)
                    .position(x: centerX, y: centerY + size * 0.35)
            }
            .frame(width: size, height: size)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: height)
    }
    private func elementButton(_ element: Element, isOn: Bool) -> some View {
        let baseColor = ElementColorDict.elementColors[element] ?? .gray
        
        return Button {
            //toggleElement(element)
        } label: {
            ZStack {
                Circle()
                    .fill(baseColor)
                    .opacity(isOn ? 1.0 : 0.5)
                    .overlay(
                        Circle()
                            .stroke(.white, lineWidth: isOn ? 4.0 : 0.0)
                    )
                    .shadow(radius: isOn ? 8 : 2)
            }
            .frame(width: 30, height: 30)
            .scaleEffect(isOn ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isOn)
        }
    }
}

#Preview("NewDeckPopup Demo") {
    DeckPopupDemo()
}
