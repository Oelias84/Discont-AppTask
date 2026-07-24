//
//  CardCarouselView.swift
//  Discont-AppTask
//
//  Created by Ofir Elias on 22/07/2026.
//

import SwiftUI
import DesignSystem

struct CardCarouselView: View {

    let items: [CardModel]
    @Binding var currentId: CardModel.ID?

    var body: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 12) {
                    ForEach(items) { item in
                        BankCardView(
                            title: item.title,
                            balance: item.balance,
                            suffix: item.suffix
                        )
                        .id(item.id)
                        .containerRelativeFrame(.horizontal)
                    }
                }
                .scrollTargetLayout()
            }
            .frame(maxHeight: 194)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $currentId)
            .scrollIndicators(.hidden)

            HStack(spacing: 8) {
                ForEach(items) { item in
                    Circle()
                        .fill(item.id == currentId ? Color.blue : Color.secondary.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }
        }
    }
}

#Preview {
    CardCarouselView(
        items: [
            CardModel(
                id: UUID(),
                title: "Sample",
                amount: 1234.56,
                suffix: "1234",
                holderName: "Alex",
                phoneNumber: "0547897898"
            )
        ],
        currentId: .constant(nil)
    )
}
