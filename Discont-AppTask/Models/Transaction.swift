//
//  Transaction.swift
//  Discont-AppTask
//
//  Created by Ofir Elias on 22/07/2026.
//

import Foundation

struct Transaction: Identifiable, Hashable, Codable {
    enum Status: String, Hashable, Codable {
        case completed, pending, failed
    }

    let id: UUID
    var title: String
    var amount: Decimal
    let currency: String
    var status: Status
    let date: Date
    let recipientName: String
    var category: String
    var note: String
}
