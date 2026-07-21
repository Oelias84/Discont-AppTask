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

    @Observable
    class ViewModel {

        var itemStore = ItemStore()
        var alert: AlertItem?
        var screenState: ScreenState = .loading
        var currentId: ItemModel.ID?
        var sum: Decimal?
        var message: String = ""

        let service: FetchItemsProtocol

        init(service: FetchItemsProtocol) {
            self.service = service
        }

        var sortedItems: [ItemModel] {
            itemStore.items.sorted { $0.title < $1.title }
        }

        var formattedSum: String {
            guard let sum else { return "" }
            return sum.formatted(.number.precision(.fractionLength(0...2)))
        }

        var continueButtonText: String {
            sum == nil ? "Transfer Money" : "Transfer \(formattedSum)$"
        }

        func attemptTransfer() -> Decimal? {
            guard let sum, sum > 0 else {
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
            return sum
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
