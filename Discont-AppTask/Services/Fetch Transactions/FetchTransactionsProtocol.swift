//
//  FetchTransactionsProtocol.swift
//  Discont-AppTask
//
//  Created by Ofir Elias on 22/07/2026.
//

import Foundation

protocol FetchTransactionsProtocol {
    func fetchTransactions(for card: CardModel) async throws -> [Transaction]
}
