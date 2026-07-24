//
//  TransferDetailsView.swift
//  Discont-AppTask
//
//  Created by Ofir Elias on 23/07/2026.
//

import SwiftUI
import DesignSystem

struct TransferDetailsView: View {

    private enum Field: Hashable {
        case amount, recipient, message
    }

    let cardTitle: String
    let cardBalance: String

    @Binding var amount: Decimal?
    @Binding var recipientName: String
    @Binding var message: String

    let onExecute: () -> Void

    @State private var amountText: String = ""
    @FocusState private var focusedField: Field?

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack {
                    VStack(spacing: 4) {
                        Text(cardTitle)
                            .font(DSFont.heading2)
                            .foregroundStyle(Color.dark)

                        Text(cardBalance)
                            .font(DSFont.caption)
                            .foregroundStyle(Color.dark.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)

                    HStack {
                        Spacer()
                        TextField("0", text: $amountText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .amount)
                            .fixedSize()

                        Text("$")
                            .foregroundStyle(Color.dark)

                        Spacer()
                    }
                    .font(.system(size: 24, weight: .regular))
                    .padding()
                    .background(Color.lightGray)
                    .padding(.top, 24)

                    Text("Commission is not charged by the bank")
                        .font(DSFont.caption)
                        .foregroundStyle(Color.dark.opacity(0.6))
                        .padding(.top, 4)

                    TextField("Recipient name", text: $recipientName)
                        .focused($focusedField, equals: .recipient)
                        .dsTextField(title: "To")
                        .padding(.top, 24)

                    TextField("Message to the recipient", text: $message, axis: .vertical)
                        .lineLimit(2, reservesSpace: true)
                        .focused($focusedField, equals: .message)
                        .padding()
                        .background(Color.lightGray)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.top, 16)
                }
                .padding()
            }

            Button("Confirm Transfer") {
                onExecute()
            }
            .buttonStyle(.primary)
            .disabled(recipientName.trimmingCharacters(in: .whitespaces).isEmpty)
            .padding()
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button {
                    focusedField = previousField
                } label: {
                    Image(systemName: "chevron.up")
                }
                .disabled(previousField == nil)

                Button {
                    focusedField = nextField
                } label: {
                    Image(systemName: "chevron.down")
                }
                .disabled(nextField == nil)

                Spacer()

                Button("Done") {
                    focusedField = nil
                }
            }
        }
        .onAppear {
            focusedField = .amount

            if let amount {
                amountText = "\(amount)"
            }
        }
        .onChange(of: amountText) { _, newValue in
            amount = newValue.isEmpty ? nil : Decimal(string: newValue)
        }
    }

    private var nextField: Field? {
        switch focusedField {
        case .amount: return .recipient
        case .recipient: return .message
        case .message, nil: return nil
        }
    }

    private var previousField: Field? {
        switch focusedField {
        case .message: return .recipient
        case .recipient: return .amount
        case .amount, nil: return nil
        }
    }
}

#Preview {
    NavigationStack {
        TransferDetailsView(
            cardTitle: "Salary card",
            cardBalance: "10,000$",
            amount: .constant(nil),
            recipientName: .constant("Alex"),
            message: .constant(""),
            onExecute: {}
        )
    }
}
