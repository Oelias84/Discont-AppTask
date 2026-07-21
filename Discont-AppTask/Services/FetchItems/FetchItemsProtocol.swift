//
//  FetchItemsProtocol.swift
//  Discont-AppTask
//
//  Created by Ofir Elias on 20/07/2026.
//

import Foundation

protocol FetchItemsProtocol {
    func fetchData() async throws -> [ItemModel]
}
