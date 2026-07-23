//
//  TransferSuccessView.swift
//  Discont-AppTask
//
//  Created by Ofir Elias on 20/07/2026.
//

import SwiftUI
import DesignSystem

struct TransferSuccessView: View {

    @Environment(\.dismiss) private var dismiss

    @State var viewModel: ViewModel
    @State private var loopMode: CheckmarkAnimationView.LoopMode = .playOnce
    @State private var isShowingReceipt = false
    @State private var showSampleCreatedAlert = false

    let onRepeat: () -> Void

    init(
        amount: Decimal,
        recipientName: String,
        message: String,
        onRepeat: @escaping () -> Void,
        card: CardModel
    ) {
        _viewModel = State(
            initialValue: ViewModel(
                card: card,
                amount: amount,
                recipientName: recipientName,
                message: message
            )
        )
        
        self.onRepeat = onRepeat
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 24) {
                CheckmarkAnimationView(loopMode: $loopMode)
                    .frame(width: 96, height: 96)

                VStack(spacing: 8) {
                    Text(viewModel.recipientName)
                        .font(DSFont.heading2)
                        .foregroundStyle(Color.dark)

                    Text(viewModel.formattedAmount)
                        .font(DSFont.heading1)
                        .foregroundStyle(Color.dark)

                    VStack(spacing: 2) {
                        Text("No commission")
                        Text("Completed, \(viewModel.completedAt)")
                    }
                    .font(DSFont.caption)
                    .foregroundStyle(Color.dark.opacity(0.6))
                }

                HStack(spacing: 12) {
                    Button("Open\nreceipt") {
                        isShowingReceipt = true
                    }
                    .buttonStyle(.cartButton(type: .receipt))

                    Button("Create\nsample") {
                        showSampleCreatedAlert = true
                    }
                    .buttonStyle(.cartButton(type: .star))

                    Button("Repeat\npayment") {
                        onRepeat()
                        dismiss()
                    }
                    .buttonStyle(.cartButton(type: .arrowClockwise))
                }

                Spacer()
            }
            .padding()

            ExpandableDrawerView(title: "Operation details") {
                operationDetailsRows()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.lightGray)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack {
                Button("To Main") {
                    dismiss()
                }
                .buttonStyle(.primary)
                .padding()
            }
            .background(Color.surface)
        }
        .overlay {
            if isShowingReceipt {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { isShowingReceipt = false }
                    .transition(.opacity)

                ReceiptView(title: "Operation details", onClose: { isShowingReceipt = false }) {
                    operationDetailsRows(isDashed: true)
                }
                .padding(.horizontal, 24)
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isShowingReceipt)
        .alert("Sample created", isPresented: $showSampleCreatedAlert) {
            Button("OK", role: .cancel) {}
        }
    }

    @ViewBuilder
    private func operationDetailsRows(isDashed: Bool = false) -> some View {
        let dividerStyle: DSRawView.DividerStyle = isDashed ? .dashed : .solid

        DSRawView(title: viewModel.card.holderName, caption: "Withdrawal account", cardInfo: .init(suffix: viewModel.card.suffix, type: .visa), dividerStyle: dividerStyle)
        DSRawView(title: viewModel.recipientName, caption: "Name of recipient", dividerStyle: dividerStyle)
        DSRawView(title: viewModel.formattedAmount, caption: "Transfer amount", dividerStyle: dividerStyle)
        DSRawView(title: "No commission", caption: "Commission", dividerStyle: dividerStyle)
        DSRawView(title: viewModel.completedAt, caption: "Date", dividerStyle: dividerStyle)

        if !viewModel.message.isEmpty {
            DSRawView(title: viewModel.message, caption: "Message", dividerStyle: dividerStyle)
        }
    }
}

#Preview {
    NavigationStack {
        TransferSuccessView(
            amount: 100,
            recipientName: "Alexander Dmitrievich",
            message: "Happy birthday!",
            onRepeat: {},
            card: CardModel(
                id: UUID(),
                title: "Sample",
                amount: 1234.56,
                suffix: "1234",
                holderName: "Alex",
                phoneNumber: "0547897898"
            )
        )
    }
}
