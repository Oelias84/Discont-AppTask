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
    @FocusState private var isMessageFocused: Bool

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
            viewModel.currentId = viewModel.itemStore.items.first?.id
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

            DSRawView(
                title: card.wrappedValue.title,
                caption: "Card name"
            )
            
            DSRawView(
                title: card.wrappedValue.phoneNumber,
                caption: card.wrappedValue.holderName,
                cardInfo: .init(
                    suffix: card.wrappedValue.suffix,
                    type: .visa
                )
            )

            VStack(alignment: .leading, spacing: 8) {
                Button {
                    viewModel.destination = .enterAmount
                } label: {
                    Text(viewModel.sum == nil ? "from 10$ to 99 999$" : "\(viewModel.formattedSum)$")
                        .foregroundStyle(viewModel.sum == nil ? Color.dark.opacity(0.4) : Color.dark)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .dsTextField(title: "Sum")

                Text("Commission is not charged by the bank")
                    .font(DSFont.caption)
                    .foregroundStyle(Color.dark.opacity(0.6))
            }
            .padding(.bottom, 16)
            
            TextField("Message to the recipient", text: $viewModel.message, axis: .vertical)
                .lineLimit(2, reservesSpace: true)
                .focused($isMessageFocused)
                .padding()
                .background(Color.lightGray)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            isMessageFocused = false
                        }
                    }
                }

            Spacer()
            
            Button("Transactions") {
                viewModel.showTransactions()
            }
            .buttonStyle(.primary)
            
            Button(viewModel.continueButtonText) {
                _ = viewModel.attemptTransfer(recipientName: card.wrappedValue.holderName)
            }
            .buttonStyle(.primary)
            .padding(.bottom)
        }
        .padding([.top, .horizontal])
        .navigationDestination(item: $viewModel.destination) { destination in
            switch destination {
            case .enterAmount:
                EnterAmountView(
                    cardTitle: card.wrappedValue.title,
                    cardBalance: card.wrappedValue.balance,
                    amount: $viewModel.sum
                )

            case .success(let amount):
                TransferSuccessView(
                    amount: amount,
                    recipientName: card.wrappedValue.holderName,
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
            }
        }
    }
}

#Preview {
    CardSelectionView(viewModel: .init(service: FetchItemsService()))
}
