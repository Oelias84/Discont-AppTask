//
//  CardSelectionView+ViewModel.swift
//  Discont-AppTask
//
//  Created by Ofir Elias on 20/07/2026.
//

import SwiftUI

extension CardSelectionView {

    enum ScreenState {
        case loading
        case zeroStare
        case dataReceived
    }

    @Observable
    class ViewModel {

        var itemStore = ItemStore()
        var alert: AlertItem?
        var screenState: ScreenState = .loading
        var currentId: ItemModel.ID?
        var sum: String = ""
        var message: String = ""

        let service: FetchItemsProtocol

        init(service: FetchItemsProtocol) {
            self.service = service
        }

        var sortedItems: [ItemModel] {
            itemStore.items.sorted { $0.title < $1.title }
        }
        
        var continueButtonText: String {
            sum.isEmpty ? "Transfer Money" : "Transfer \(sum)$"
        }

        func attemptTransfer() -> Bool {
            guard !sum.trimmingCharacters(in: .whitespaces).isEmpty else {
                alert = AlertItem(
                    id: UUID(),
                    title: "Amount required",
                    message: "Please enter an amount to transfer."
                )
                return false
            }

            return true
        }

        func fetchItems() async {
            do {
                itemStore.items = try await service.fetchData()

            } catch {
                alert = AlertItem(id: UUID(), title: "Error", message: error.localizedDescription)
            }

            screenState = itemStore.items.isEmpty ? .zeroStare : .dataReceived
        }
    }
}
