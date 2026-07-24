//
//  TransactionDetailView.swift
//  Discont-AppTask
//
//  Created by Ofir Elias on 23/07/2026.
//

import SwiftUI
import DesignSystem

struct TransactionDetailView: View {
    
    @State var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isNoteFocused: Bool

    var body: some View {
        VStack(alignment: . leading, spacing: 20) {
            VStack(spacing: 4) {
                
                Text(viewModel.formattedAmount)
                    .font(DSFont.heading1)
                    .foregroundStyle(viewModel.transaction.amount < 0 ? Color.dark : Color.main)
                
                
                Text(viewModel.transaction.title)
                    .font(DSFont.heading2)
                    .foregroundStyle(Color.dark)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            
            DSRawView(title: viewModel.directionLabel, caption: "Type")
            DSRawView(title: viewModel.transaction.recipientName, caption: "Recipient")
            DSRawView(title: viewModel.formattedDate, caption: "Date")
            DSRawView(title: viewModel.transaction.status.rawValue.capitalized, caption: "Status")
            
            TextField("Category", text: $viewModel.category)
                .dsTextField(title: "Category")

            TextField("Add a note", text: $viewModel.note, axis: .vertical)
                .lineLimit(2, reservesSpace: true)
                .focused($isNoteFocused)
                .dsTextField(title: "Note")
            
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isNoteFocused = false
                    }
                }
            }
            
            Spacer()
            
            Button("Save") {
                viewModel.save()
                dismiss()
            }
            .buttonStyle(.primary)
        }
        .padding()
        .navigationTitle("Transaction")
        .navigationBarTitleDisplayMode(.inline)
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
    let transaction = Transaction(
        id: UUID(),
        title: "Coffee Shop",
        amount: -12.5,
        currency: "USD",
        status: .completed,
        date: .now,
        recipientName: "Blue Bottle",
        category: "Dining",
        note: ""
    )
    store.items = [card]
    
    return NavigationStack {
        TransactionDetailView(
            viewModel: .init(repository: store, cardID: card.id, transaction: transaction)
        )
    }
}
