//
//  CardSelectionView.swift
//  Discont-AppTask
//
//  Created by Ofir Elias on 20/07/2026.
//

import SwiftUI
import DesignSystem

struct CardSelectionView: View {

    @State var viewModel = ViewModel(service: FetchItemsService())
    @State private var isEnteringAmount = false
    @State private var showSuccess = false
    @State private var isRepeatingPayment = false
    @FocusState private var isMessageFocused: Bool

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.screenState {
                case .loading:
                    ProgressView()

                case .zeroStare:
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
    private func content(for card: Binding<ItemModel>) -> some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 12) {
                        ForEach(viewModel.itemStore.items) { item in
                            BankCardView(
                                title: item.title,
                                balance: item.balance,
                                suffix: item.suffix
                            )
                            .id(item.id)
                            .containerRelativeFrame(.horizontal)
                        }
                    }
                    .scrollTargetLayout()
                }
                .frame(height: 194)
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $viewModel.currentId)
                .scrollIndicators(.hidden)

                HStack(spacing: 8) {
                    ForEach(viewModel.itemStore.items) { item in
                        Circle()
                            .fill(item.id == viewModel.currentId ? Color.blue : Color.secondary.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
            }

            TextField("Card name", text: card.title)
                .dsTextField(title: "Card name")

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
                    isEnteringAmount = true
                    
                } label: {
                    Text(viewModel.sum.isEmpty ? "from 10$ to 99 999$" : "\(viewModel.sum)$")
                        .foregroundStyle(viewModel.sum.isEmpty ? Color.dark.opacity(0.4) : Color.dark)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .dsTextField(title: "Sum")

                Text("Commission is not charged by the bank")
                    .font(DSFont.caption)
                    .foregroundStyle(Color.dark.opacity(0.6))
            }
            .navigationDestination(isPresented: $isEnteringAmount) {
                EnterAmountView(
                    cardTitle: card.wrappedValue.title,
                    cardBalance: card.wrappedValue.balance,
                    amount: $viewModel.sum
                )
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

            Button(viewModel.continueButtonText) {
                guard viewModel.attemptTransfer() else { return }
                showSuccess = true
            }
            .padding(.bottom)
            .buttonStyle(.primary)
            .navigationDestination(isPresented: $showSuccess) {
                TransferSuccessView(
                    amount: viewModel.sum,
                    recipientName: card.wrappedValue.holderName,
                    message: viewModel.message,
                    onRepeat: { isRepeatingPayment = true },
                    card: card
                )
            }
            .onChange(of: showSuccess) { _, isShowingSuccess in
                guard !isShowingSuccess else { return }

                if isRepeatingPayment {
                    isRepeatingPayment = false
                } else {
                    viewModel.sum = ""
                    viewModel.message = ""
                }
            }
        }
        .padding([.top, .horizontal])
    }
}

#Preview {
    CardSelectionView()
}
