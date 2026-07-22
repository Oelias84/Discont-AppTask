//
//  CardModel.swift
//  Discont-AppTask
//
//  Created by Ofir Elias on 20/07/2026.
//

import Foundation

struct CardModel: Identifiable, Hashable {
    let id: UUID
    var title: String
    var amount: Decimal
    var suffix: String
    var holderName: String
    var phoneNumber: String

    var balance: String {
        amount.formatted(.number.precision(.fractionLength(2))) + "$"
    }
}
