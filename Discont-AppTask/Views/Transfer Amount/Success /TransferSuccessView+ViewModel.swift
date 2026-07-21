//
//  TransferSuccessView+ViewModel.swift
//  Discont-AppTask
//
//  Created by Ofir Elias on 20/07/2026.
//

import SwiftUI

extension TransferSuccessView {

    @Observable
    class ViewModel {

        let amount: String
        let recipientName: String
        let message: String

        init(amount: String, recipientName: String, message: String) {
            self.amount = amount
            self.recipientName = recipientName
            self.message = message
        }

        var completedAt: String {
            Date.now.formatted(date: .abbreviated, time: .shortened)
        }

        func applyDeduction(to card: inout ItemModel) {
            guard let transferredAmount = Double(amount) else { return }
            card.amount -= transferredAmount
            card.balance = String(format: "%.2f$", card.amount)
        }
    }
}
