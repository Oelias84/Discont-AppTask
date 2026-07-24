//
//  CardSelectionView.swift
//  Discont-AppTask
//
//  Created by Ofir Elias on 20/07/2026.
//

import SwiftUI
import DesignSystem

struct CardSelectionView: View {

    @State var viewModel: ViewModel
    @State private var isRepeatingPayment = false

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.screenState {
                case .loading:
                    ProgressView()

                case .zeroState:
                    VStack {
                        Image(systemName: "tray")
                        Text("No cards found")
                    }

                case .dataReceived:
                    if let currentIndex {
                        content(for: $viewModel.itemStore.items[currentIndex])
                    }
                }
            }
        }
        .task {
            await viewModel.fetchItems()
            viewModel.currentId = viewModel.sortedItems.first?.id
        }
        .alert(item: $viewModel.alert) {
            Alert(
                title: Text($0.title),
                message: Text($0.message)
            )
        }
    }
    
    private var currentIndex: Int? {
        viewModel.itemStore.items.firstIndex { $0.id == viewModel.currentId }
    }

    @ViewBuilder
    private func content(for card: Binding<CardModel>) -> some View {
        VStack(spacing: 16) {
            
            CardCarouselView(items: viewModel.sortedItems, currentId: $viewModel.currentId)
            
            Button {
                viewModel.showTransactions()
            } label: {
                HStack {
                    Text("Transactions information")
                    Image(systemName: "chevron.right")
                }
            }
            .buttonStyle(.glassProminent)
            .padding(.bottom)
            
            DSRawView(
                title: card.wrappedValue.title,
                caption: "Card Description"
            )
            
            DSRawView(
                title: card.wrappedValue.holderName,
                caption: "Holder Name"
            )
            
            DSRawView(
                title: card.wrappedValue.phoneNumber,
                caption: "Contact Information"
            )

            Spacer()

            Button("Transfer Money") {
                viewModel.destination = .transfer
            }
            .buttonStyle(.primary)
            .disabled(card.wrappedValue.amount <= 0)
            .padding(.bottom)
        }
        .padding([.top, .horizontal])
        .navigationDestination(item: $viewModel.destination) { destination in
            switch destination {
            case .transfer:
                TransferDetailsView(
                    cardTitle: card.wrappedValue.title,
                    cardBalance: card.wrappedValue.balance,
                    amount: $viewModel.sum,
                    recipientName: $viewModel.recipientName,
                    message: $viewModel.message,
                    onExecute: {
                        _ = viewModel.attemptTransfer(recipientName: viewModel.recipientName)
                    }
                )

            case .success(let amount):
                TransferSuccessView(
                    amount: amount,
                    recipientName: viewModel.recipientName,
                    message: viewModel.message,
                    onRepeat: { isRepeatingPayment = true },
                    card: card.wrappedValue
                )

            case .transactions:
                if let transactionsViewModel = viewModel.transactionsViewModel {
                    TransactionsListView(viewModel: transactionsViewModel)
                }
            }
        }
        .onChange(of: viewModel.destination) { oldValue, newValue in
            guard newValue == nil, case .success = oldValue else { return }

            if isRepeatingPayment {
                isRepeatingPayment = false
            } else {
                viewModel.sum = nil
                viewModel.message = ""
                viewModel.recipientName = ""
            }
        }
    }
}

#Preview {
    CardSelectionView(viewModel: .init(service: FetchItemsService()))
}
