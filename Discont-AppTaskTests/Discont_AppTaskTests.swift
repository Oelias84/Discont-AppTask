//
//  Discont_AppTaskTests.swift
//  Discont-AppTaskTests
//
//  Created by Ofir Elias on 15/07/2026.
//

import XCTest
@testable import Discont_AppTask

private struct MockFetchItemsService: FetchItemsProtocol {
    var items: [CardModel] = []

    func fetchData() async throws -> [CardModel] {
        items
    }
}

private func makeItem(title: String = "Salary card", amount: Decimal = 100) -> CardModel {
    CardModel(id: UUID(), title: title, amount: amount, suffix: "1234", holderName: "Holder", phoneNumber: "000")
}

@MainActor
final class CardSelectionViewModelTests: XCTestCase {

    func testAttemptTransfer_withNoAmount_setsAlertAndReturnsNil() {
        let viewModel = CardSelectionView.ViewModel(service: MockFetchItemsService())
        let card = makeItem(amount: 100)
        viewModel.itemStore.items = [card]
        viewModel.currentId = card.id
        viewModel.sum = nil

        let result = viewModel.attemptTransfer()

        XCTAssertNil(result)
        XCTAssertEqual(viewModel.alert?.title, "Amount required")
    }

    func testAttemptTransfer_withAmountExceedingBalance_setsAlertAndReturnsNil() {
        let viewModel = CardSelectionView.ViewModel(service: MockFetchItemsService())
        let card = makeItem(amount: 50)
        viewModel.itemStore.items = [card]
        viewModel.currentId = card.id
        viewModel.sum = 75

        let result = viewModel.attemptTransfer()

        XCTAssertNil(result)
        XCTAssertEqual(viewModel.alert?.title, "Insufficient funds")
    }

    func testAttemptTransfer_withValidAmount_returnsAmountAndSetsNoAlert() {
        let viewModel = CardSelectionView.ViewModel(service: MockFetchItemsService())
        let card = makeItem(amount: 200)
        viewModel.itemStore.items = [card]
        viewModel.currentId = card.id
        viewModel.sum = 150

        let result = viewModel.attemptTransfer()

        XCTAssertEqual(result, 150)
        XCTAssertNil(viewModel.alert)
    }

    func testAttemptTransfer_withValidAmount_deductsCardBalance() {
        let viewModel = CardSelectionView.ViewModel(service: MockFetchItemsService())
        let card = makeItem(amount: 200)
        viewModel.itemStore.items = [card]
        viewModel.currentId = card.id
        viewModel.sum = 150

        _ = viewModel.attemptTransfer()

        XCTAssertEqual(viewModel.itemStore.items[0].amount, 50)
    }

    func testAttemptTransfer_withInsufficientFunds_doesNotDeductCardBalance() {
        let viewModel = CardSelectionView.ViewModel(service: MockFetchItemsService())
        let card = makeItem(amount: 50)
        viewModel.itemStore.items = [card]
        viewModel.currentId = card.id
        viewModel.sum = 75

        _ = viewModel.attemptTransfer()

        XCTAssertEqual(viewModel.itemStore.items[0].amount, 50)
    }

    func testFetchItems_withResults_setsDataReceivedState() async {
        let items = [makeItem(title: "B card"), makeItem(title: "A card")]
        let viewModel = CardSelectionView.ViewModel(service: MockFetchItemsService(items: items))

        await viewModel.fetchItems()

        XCTAssertEqual(viewModel.screenState, .dataReceived)
        XCTAssertEqual(viewModel.itemStore.items.count, 2)
    }

    func testFetchItems_withNoResults_setsZeroState() async {
        let viewModel = CardSelectionView.ViewModel(service: MockFetchItemsService(items: []))

        await viewModel.fetchItems()

        XCTAssertEqual(viewModel.screenState, .zeroState)
    }

    func testSortedItems_areOrderedByTitle() {
        let viewModel = CardSelectionView.ViewModel(service: MockFetchItemsService())
        viewModel.itemStore.items = [
            makeItem(title: "Savings"),
            makeItem(title: "Business"),
            makeItem(title: "Main")
        ]

        XCTAssertEqual(viewModel.sortedItems.map(\.title), ["Business", "Main", "Savings"])
    }
}

@MainActor
final class TransferSuccessViewModelTests: XCTestCase {

    func testFormattedAmount_includesDollarSuffix() {
        let viewModel = TransferSuccessView.ViewModel(amount: 100, recipientName: "Alex", message: "")

        XCTAssertEqual(viewModel.formattedAmount, "100$")
    }
}
