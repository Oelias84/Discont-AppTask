//
//  ItemStore.swift
//  Discont-AppTask
//
//  Created by Ofir Elias on 20/07/2026.
//

import SwiftUI

@Observable
final class CardsStore: CardsRepositoryProtocol {
    var items: [CardModel] = []

    func card(id: CardModel.ID) -> CardModel? {
        items.first { $0.id == id }
    }
    
    func updateCard(_ card: CardModel) {
        guard let index = items.firstIndex(where: { $0.id == card.id }) else { return }
        items[index] = card
    }
    
}
