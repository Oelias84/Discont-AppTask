//
//  ItemModel.swift
//  Discont-AppTask
//
//  Created by Ofir Elias on 20/07/2026.
//

import Foundation

struct ItemModel: Identifiable, Hashable {
    let id: UUID
    var title: String
    var amount: Double
    var balance: String
    var suffix: String
    var holderName: String
    var phoneNumber: String
}
