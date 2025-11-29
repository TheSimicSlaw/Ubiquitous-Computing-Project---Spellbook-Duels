//
//  CardZoneViews.swift
//  Spellbook Duels
//
//  Created by Rocky Williams on 11/28/25.
//

import SwiftUI

struct CurseCardView: View {
    @State var cardCode: String
    
    var body: some View {
        if let card = PresentedCardModel.cardByCode[cardCode] {
            Menu {
                Button("View Details") {
                    
                }
                Button("Activate") {
                    
                }
            } label: {
                Image(uiImage: card.icon!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
            }
        } else {
            Rectangle()
                .stroke(.white, lineWidth: 2)
                .frame(width: 60, height: 60)
        }
    }
}

struct SnapCardView: View {
    @State var cardCode: String
    
    var body: some View {
        if let card = PresentedCardModel.cardByCode[cardCode] {
            Menu {
                Button("View Details") {
                    
                }
                Button("Activate") {
                    
                }
            } label: {
                Image(uiImage: card.icon!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
            }
        } else {
            Rectangle()
                .stroke(.white, lineWidth: 2)
                .frame(width: 80, height: 80)
        }
    }
}

struct WardCardView: View {
    @State var cardCode: String
    
    var body: some View {
        if let card = PresentedCardModel.cardByCode[cardCode] {
            Menu {
                Button("View Details") {
                    
                }
                Button("Activate") {
                    
                }
            } label: {
                Image(uiImage: card.icon!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
            }
        } else {
            Rectangle()
                .stroke(.white, lineWidth: 2)
                .frame(width: 60, height: 60)
        }
    }
}

struct CharmCardView: View {
    @State var cardCode: String
    
    var body: some View {
        if let card = PresentedCardModel.cardByCode[cardCode] {
            Menu {
                Button("View Details") {
                    
                }
                Button("Activate") {
                    
                }
            } label: {
                Image(uiImage: card.icon!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
            }
        } else {
            Rectangle()
                .stroke(.white, lineWidth: 2)
                .frame(width: 60, height: 60)
        }
    }
}

struct RelicCardView: View {
    @State var cardCode: String
    
    var body: some View {
        if let card = PresentedCardModel.cardByCode[cardCode] {
            Menu {
                Button("View Details") {
                    
                }
                Button("Activate") {
                    
                }
            } label: {
                Image(uiImage: card.icon!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
            }
        } else {
            Rectangle()
                .stroke(.white, lineWidth: 2)
                .frame(width: 60, height: 60)
        }
    }
}

struct PotionCardView: View {
    @State var cardCode: String
    
    var body: some View {
        if let card = PresentedCardModel.cardByCode[cardCode] {
            Menu {
                Button("View Details") {
                    
                }
                Button("Activate") {
                    
                }
            } label: {
                Image(uiImage: card.icon!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
            }
        } else {
            Rectangle()
                .stroke(.white, lineWidth: 2)
                .frame(width: 60, height: 60)
        }
    }
}

struct HandZoneView: View {
    @State var cardCode: String
    
    var body: some View {
        if let card = PresentedCardModel.cardByCode[cardCode] {
            HStack {
                Menu {
                    Button("View Details") {
                        
                    }
                    Button("Activate") {
                        
                    }
                } label: {
                    Image(uiImage: card.icon!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                }
                Text("\(card.cardCode)")
                    .font(.custom("InknutAntiqua-Regular", size: 10))
            }
            
        } else {
            HStack {
                Rectangle()
                    .stroke(.white, lineWidth: 2)
                    .frame(width: 40, height: 40)
                Text("---")
            }
            
        }
    }
}

