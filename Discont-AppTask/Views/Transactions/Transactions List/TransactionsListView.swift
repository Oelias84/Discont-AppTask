//
//  TransactionsListView.swift
//  Discont-AppTask
//
//  Created by Ofir Elias on 22/07/2026.
//

import SwiftUI
import DesignSystem

struct TransactionsListView: View {

    @State var viewModel: ViewModel

    var body: some View {
        Group {
            switch viewModel.screenState {
            case .loading:
                ProgressView()

            case .zeroState:
                VStack {
                    Image(systemName: "tray")
                    Text("No transactions found")
                }

            case .dataReceived:
                List(viewModel.sortedTransactions) { transaction in
                    NavigationLink {
                        TransactionDetailView(viewModel: viewModel.makeDetailViewModel(for: transaction))
                    } label: {
                        let formattedAmount = transaction.amount.formatted(.number.precision(.fractionLength(0...2)))

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(transaction.title)
                                    .font(DSFont.heading2Regular)
                                    .foregroundStyle(Color.dark)

                                Spacer()

                                Text("\(formattedAmount)$")
                                    .foregroundStyle(transaction.amount < 0 ? Color.dark : Color.main)
                            }

                            Text(transaction.category)
                                .font(DSFont.caption)
                                .foregroundStyle(Color.dark.opacity(0.6))
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
                .searchable(text: $viewModel.serachText)
            }
        }
        .navigationTitle("Transactions")
        .onAppear {
            Task {
                await viewModel.fetchTransactions()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(TransactionsListView.SortOrder.allCases, id: \.self) { item in
                        Button(item.rawValue) { viewModel.sortOrder = item }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu("", systemImage: "line.3.horizontal.decrease.circle") {
                    ForEach(TransactionsListView.DirectionFilter.allCases, id: \.self) { item in
                        Button(item.rawValue.capitalized) { viewModel.directionFilter = item }
                    }
                }

            }
        }
        .alert(item: $viewModel.alert) {
            Alert(
                title: Text($0.title),
                message: Text($0.message)
            )
        }
    }
}

#Preview {
    let store = CardsStore()
    let card = CardModel(
        id: UUID(),
        title: "Sample",
        amount: 1234.56,
        suffix: "1234",
        holderName: "Alex",
        phoneNumber: "0547897898"
    )
    store.items = [card]

    return NavigationStack {
        TransactionsListView(
            viewModel: .init(
                cardsStore: store,
                cardID: card.id,
                service: FetchTransactionsService()
            )
        )
    }
}
