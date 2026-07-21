//
//  EnterAmountView.swift
//  Discont-AppTask
//
//  Created by Ofir Elias on 20/07/2026.
//

import SwiftUI
import DesignSystem

struct EnterAmountView: View {

    let cardTitle: String
    let cardBalance: String
    
    @Binding var amount: String
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    var body: some View {
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
                TextField("0", text: $amount)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .focused($isFocused)
                    .fixedSize()

                Text("$")
                    .foregroundStyle(Color.dark)
                
                Spacer()
            }
            .font(.system(size: 24, weight: .regular))
            .padding()
            .background(Color.lightGray)
            .padding(.top, 24)

            Spacer()

            HStack {
                Spacer()
                Button("Ready") {
                    dismiss()
                }
                .buttonStyle(.primary)
                .frame(width: 120)
            }
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isFocused = true
        }
    }
}

#Preview {
    NavigationStack {
        EnterAmountView(
            cardTitle: "Salary card",
            cardBalance: "10,000$",
            amount: .constant("")
        )
    }
}
