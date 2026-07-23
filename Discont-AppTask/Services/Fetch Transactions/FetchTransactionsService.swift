//
//  FetchTransactionsService.swift
//  Discont-AppTask
//
//  Created by Ofir Elias on 22/07/2026.
//

import Foundation

class FetchTransactionsService: FetchTransactionsProtocol {

    private let sampleTitles = [
        "Grocery Store", "Coffee Shop", "Online Purchase", "Salary Deposit",
        "Electric Bill", "Rent Payment", "Restaurant", "Gas Station",
        "Subscription", "ATM Withdrawal"
    ]

    private let sampleCategories = [
        "Groceries", "Dining", "Shopping", "Income", "Utilities", "Housing", "Transport", "Entertainment"
    ]

    private let sampleNames = [
        "Alexander Dmitrievich", "Maria Ivanova", "John Carter", "Sofia Petrova"
    ]

    func fetchTransactions(for card: CardModel) async throws -> [Transaction] {
        try await Task.sleep(nanoseconds: 800_000_000) // simulate network latency

        return (0..<10_000).map { index in
            let rawAmount = Double.random(in: -2_500...2_500)
            let amount = Decimal((rawAmount * 100).rounded() / 100)
            let status: Transaction.Status = [.completed, .completed, .completed, .pending, .failed].randomElement() ?? .completed
            let daysAgo = Double.random(in: 0...365)

            return Transaction(
                id: UUID(),
                title: sampleTitles[index % sampleTitles.count],
                amount: amount,
                currency: "USD",
                status: status,
                date: Date.now.addingTimeInterval(-daysAgo * 86_400),
                recipientName: sampleNames[index % sampleNames.count],
                category: sampleCategories[index % sampleCategories.count],
                note: ""
            )
        }
    }
}
