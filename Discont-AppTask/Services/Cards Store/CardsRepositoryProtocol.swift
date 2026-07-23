//
//  CardsRepositoryProtocol.swift
//  Discont-AppTask
//
//  Created by Ofir Elias on 23/07/2026.
//

import Foundation

protocol CardsRepositoryProtocol {
    func card(id: CardModel.ID) -> CardModel?
    func updateCard(_ card: CardModel)
}
