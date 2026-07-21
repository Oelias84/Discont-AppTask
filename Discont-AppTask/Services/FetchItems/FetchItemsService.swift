//
//  FetchItemsService.swift
//  Discont-AppTask
//
//  Created by Ofir Elias on 20/07/2026.
//

import Foundation

class FetchItemsService: FetchItemsProtocol {

    private let sampleTitles = [
        "Salary card", "Savings account", "Main card", "Business card"
    ]

    private let sampleHolderNames = [
        "Alexander Dmitrievich", "Maria Ivanova", "John Carter", "Sofia Petrova"
    ]

    func fetchData() async throws -> [ItemModel] {
        try await Task.sleep(nanoseconds: 800_000_000) // simulate network latency

        return (0..<sampleTitles.count).map { index in
            let rawAmount = Double.random(in: -250...500)
            let amount = Decimal((rawAmount * 100).rounded() / 100)
            let suffix = String(format: "%04d", Int.random(in: 0...9999))
            let phoneNumber = String(format: "+995 5%02d %02d %02d", Int.random(in: 0...99), Int.random(in: 0...99), Int.random(in: 0...99))

            return ItemModel(
                id: UUID(),
                title: sampleTitles[index % sampleTitles.count],
                amount: amount,
                suffix: suffix,
                holderName: sampleHolderNames[index % sampleHolderNames.count],
                phoneNumber: phoneNumber
            )
        }
    }
}
