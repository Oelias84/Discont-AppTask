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

        let amount: Decimal
        let recipientName: String
        let message: String

        init(amount: Decimal, recipientName: String, message: String) {
            self.amount = amount
            self.recipientName = recipientName
            self.message = message
        }

        var completedAt: String {
            Date.now.formatted(date: .abbreviated, time: .shortened)
        }

        var formattedAmount: String {
            amount.formatted(.number.precision(.fractionLength(0...2))) + "$"
        }
    }
}
