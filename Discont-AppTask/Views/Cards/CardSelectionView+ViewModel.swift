//
//  CardSelectionView+ViewModel.swift
//  Discont-AppTask
//
//  Created by Ofir Elias on 20/07/2026.
//

import SwiftUI

extension CardSelectionView {

    enum ScreenState: Equatable {
        case loading
        case zeroState
        case dataReceived
    }

    enum Destination: Identifiable, Hashable {
        case transfer
        case success(amount: Decimal)
        case transactions

        var id: Self { self }
    }

    @MainActor
    @Observable
    class ViewModel {

        var itemStore = CardsStore()
        
        var destination: Destination?
        var transactionsViewModel: TransactionsListView.ViewModel?
        
        var currentId: CardModel.ID?
        var sum: Decimal?
        var recipientName: String = ""
        var message: String = ""

        var screenState: ScreenState = .loading
        var alert: AlertItem?

        private let service: FetchItemsProtocol

        init(service: FetchItemsProtocol) {
            self.service = service
        }

        var sortedItems: [CardModel] {
            itemStore.items.sorted { $0.title < $1.title }
        }

        func attemptTransfer(recipientName: String) -> Decimal? {
            guard !recipientName.trimmingCharacters(in: .whitespaces).isEmpty else {
                alert = AlertItem(
                    id: UUID(),
                    title: "Recipient required",
                    message: "Please enter who you're transferring to."
                )
                return nil
            }

            guard let sum, sum >= 0 else {
                alert = AlertItem(
                    id: UUID(),
                    title: "Amount required",
                    message: "Please enter an amount to transfer."
                )
                return nil
            }

            guard let index = itemStore.items.firstIndex(where: { $0.id == currentId }), sum <= itemStore.items[index].amount else {
                alert = AlertItem(
                    id: UUID(),
                    title: "Insufficient funds",
                    message: "This card's balance is too low for this transfer."
                )
                return nil
            }

            itemStore.items[index].amount -= sum

            let transaction = Transaction(
                id: UUID(),
                title: "Transfer to \(recipientName)",
                amount: -sum,
                currency: "USD",
                status: .completed,
                date: .now,
                recipientName: recipientName,
                category: "Transfer",
                note: message
            )
            
            itemStore.items[index].transactions.append(transaction)

            destination = .success(amount: sum)
            
            return sum
        }

        func showTransactions() {
            guard let currentId else { return }
            
            let transactionsService = FetchTransactionsService()
            
            let transactionsViewModel = TransactionsListView.ViewModel(
                cardsStore: itemStore,
                cardID: currentId,
                service: transactionsService
            )
            
            self.transactionsViewModel = transactionsViewModel

            destination = .transactions
        }

        func fetchItems() async {
            do {
                itemStore.items = try await service.fetchData()

            } catch {
                alert = AlertItem(id: UUID(), title: "Error", message: error.localizedDescription)
            }

            screenState = itemStore.items.isEmpty ? .zeroState : .dataReceived
        }
    }
}
