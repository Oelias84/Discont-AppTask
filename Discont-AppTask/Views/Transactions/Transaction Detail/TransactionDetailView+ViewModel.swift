//
//  TransactionDetailView+ViewModel.swift
//  Discont-AppTask
//
//  Created by Ofir Elias on 23/07/2026.
//

import SwiftUI

extension TransactionDetailView {

    @MainActor
    @Observable
    class ViewModel {

        private let repository: CardsRepositoryProtocol
        private let cardID: CardModel.ID

        var transaction: Transaction

        init(repository: CardsRepositoryProtocol, cardID: CardModel.ID, transaction: Transaction) {
            self.repository = repository
            self.cardID = cardID
            self.transaction = transaction
        }

        var formattedAmount: String {
            let magnitude = abs(transaction.amount).formatted(.number.precision(.fractionLength(0...2)))
            return transaction.amount < 0 ? "-\(magnitude)$" : "+\(magnitude)$"
        }

        var formattedDate: String {
            transaction.date.formatted(date: .abbreviated, time: .shortened)
        }

        var category: String {
            get { transaction.category }
            set { transaction.category = newValue }
        }

        var note: String {
            get { transaction.note }
            set { transaction.note = newValue }
        }

        func save() {
            repository.updateTransaction(cardID: cardID, transaction)
        }
    }
}
