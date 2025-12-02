//
//  SelectCardsView.swift
//  Spellbook Duels
//
//  Created by Ryan Camp on 12/1/25.
//

import SwiftUI

struct SelectCardsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selected = Set<Int>()
    @State private var previewCard: PresentedCardModel? = nil
    @State private var isShowingPreview: Bool = false
    
    let cards: [String]
    let numCardsToSelect: Int
    let onConfirm: ([String], [String]) -> Void
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(Color.menuBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // MARK: Title
                    Text("Select \(numCardsToSelect) card\(numCardsToSelect == 1 ? "" : "s") (\(selected.count)/\(numCardsToSelect)):")
                        .font(.custom("InknutAntiqua-Bold", size: 20))
                    
                    // MARK: Card Entries
                    List {
                        ForEach(cards.indices, id: \.self) { index in
                            if let card = PresentedCardModel.cardByCode[cards[index]] {
                                HStack(spacing: 2) {
                                    Button {
                                        toggleSelected(index)
                                    } label: {
                                        HStack {
                                            Text(card.name)
                                                .font(.custom("InknutAntiqua-Regular", size: 14))
                                                .foregroundStyle(.black)
                                            Spacer()
                                        
                                            if selected.contains(index) {
                                                Image(systemName: "checkmark")
                                                    .padding(.trailing, 5)
                                            }
                                        }
                                        .padding(.vertical, 6)
                                        .padding(.leading, 8)
                                        .contentShape(Rectangle())
                                    }
                                    
                                    Button {
                                        previewCard = card
                                        isShowingPreview = true
                                    } label: {
                                        Image(systemName: "eye")
                                            .font(.system(size: 14, weight: .bold))
                                            .padding(8)
                                            .foregroundStyle(Color.accentOne)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(ElementColorDict.elementColors[card.element]!)
                                                    .stroke(Color.accentTwo, lineWidth: 1)
                                            )
                                        
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 8)
                                .contentShape(Rectangle()) // whole row tappable
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            selected.contains(index) ? Color.accentOne.opacity(0.3) : Color.clear
                                        )
                                )
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.menuBackground)
                    
                    // MARK: Confirm button
                    VStack(spacing: 8) {
                        Button {
                            var toAdd: [String] = []
                            var notAdded: [String] = []
                            for index: Int in 0..<cards.count {
                                if selected.contains(index) {
                                    toAdd.append(cards[index])
                                } else {
                                    notAdded.append(cards[index])
                                }
                            }
                            onConfirm(toAdd, notAdded)
                            dismiss()
                        } label: {
                            Text("Confirm")
                                .font(.custom("InknutAntiqua-Bold", size: 15))
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(
                                    selected.count == numCardsToSelect
                                    ? Color.accentOne
                                    : Color.gray.opacity(0.5)
                                )
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }
                        .disabled(selected.count != numCardsToSelect)
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $isShowingPreview) {
            if let card = previewCard {
                DetailedCardView(card: card)
            } else {
                Text("No card selected")
            }
        }
    }
    
    // MARK: Toggle
    private func toggleSelected(_ index: Int) {
        if selected.contains(index) {
            selected.remove(index)
        } else {
            selected.insert(index)
        }
    }
}

// MARK: - Preview
#Preview {
    let sampleCards = PresentedCardModel.fullCardList
        .prefix(10)
        .map { $0.cardCode }
    
    SelectCardsView(cards: sampleCards, numCardsToSelect: 2) {_,_ in 
        
    }
}
