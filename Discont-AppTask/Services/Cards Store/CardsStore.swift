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
    
    func transaction(cardID: CardModel.ID, transactionID: Transaction.ID) -> Transaction? {
        card(id: cardID)?.transactions.first { $0.id == transactionID }
    }
    
    func updateTransaction(cardID: CardModel.ID, _ transaction: Transaction) {
        guard let cardIndex = items.firstIndex(where: {$0.id == cardID}),
              let transIndex = items[cardIndex].transactions.firstIndex(where: {$0.id == transaction.id}) else { return }
        
        items[cardIndex].transactions[transIndex] = transaction
    }
}
