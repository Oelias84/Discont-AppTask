//
//  TransactionsListView+ViewModel.swift
//  Discont-AppTask
//
//  Created by Ofir Elias on 22/07/2026.
//

import SwiftUI

extension TransactionsListView {

    enum SortOrder: String, CaseIterable {
        case newestFirst = "New first"
        case oldestFirst = "Old first"
        case lowerAmountFirst = "Lower amount firs"
        case higherAmountFirst = "Higher amount first"
    }
    
    enum DirectionFilter: String, CaseIterable {
        case all
        case incoming
        case outgoing
    }
    
    enum ScreenState: Equatable { case loading, zeroState, dataReceived }

    @MainActor
    @Observable
    class ViewModel {

        private var cardID: CardModel.ID
        private var cardsStore: CardsRepositoryProtocol
        
        var sortOrder: SortOrder = .newestFirst
        var directionFilter: DirectionFilter = .all

        var serachText: String = ""
        var screenState: ScreenState = .loading
        var alert: AlertItem?

        private let service: FetchTransactionsProtocol

        init(
            cardsStore: CardsRepositoryProtocol,
            cardID: CardModel.ID,
            service: FetchTransactionsProtocol
        ) {
            self.cardsStore = cardsStore
            self.cardID = cardID
            self.service = service
        }

        var sortedTransactions: [Transaction] {
            var allTransactions = cardsStore.card(id: cardID)?.transactions  ?? []
            
            // search by transaction name
            if !serachText.isEmpty {
                allTransactions = allTransactions.filter { $0.title.lowercased().contains(serachText.lowercased()) }
            }
            
            let filterdTransactions = filtered(allTransactions)
            
            let sortedTransactions = sorted(filterdTransactions)
            
            return sortedTransactions
        }
                
        private func sorted(_ transactions: [Transaction]) -> [Transaction] {
            switch sortOrder {
            case .newestFirst: return transactions.sorted { $0.date > $1.date }
            case .oldestFirst: return transactions.sorted { $0.date < $1.date }
            case .lowerAmountFirst: return transactions.sorted { $0.amount < $1.amount }
            case .higherAmountFirst: return transactions.sorted {$0.amount > $1.amount }
            }
        }

        private func filtered(_ transactions: [Transaction]) -> [Transaction] {
            switch directionFilter {
            case .all: return transactions
            case .incoming: return transactions.filter { $0.amount > 0 }
            case .outgoing: return transactions.filter { $0.amount < 0 }
            }
        }

        func makeDetailViewModel(for transaction: Transaction) -> TransactionDetailView.ViewModel {
            TransactionDetailView.ViewModel(repository: cardsStore, cardID: cardID, transaction: transaction)
        }

        func fetchTransactions() async {
            guard let card = cardsStore.card(id: cardID) else { return }

            guard card.transactions.count < 10_000 else {
                screenState = .dataReceived
                return
            }

            do {
                let fetched = try await service.fetchTransactions(for: card)
                var updateCard = card
                updateCard.transactions = card.transactions + fetched
                cardsStore.updateCard(updateCard)
                screenState = updateCard.transactions.isEmpty ? .zeroState : .dataReceived
            } catch {
                alert = AlertItem(id: UUID(), title: "Error", message: error.localizedDescription)
            }
        }
    }
}
