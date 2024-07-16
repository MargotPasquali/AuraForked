//
//  AllTransactionsView.swift
//  Aura
//
//  Created by Margot Pasquali on 16/07/2024.
//

import SwiftUI

struct AllTransactionsView: View {
    @Binding var showAllTransactions: Bool

    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                showAllTransactions.toggle()
            }) {
                HStack {
                    Image(systemName: showAllTransactions ? "chevron.up.circle.fill" : "list.bullet")
                    Text(showAllTransactions ? "See Less Transactions" : "See More Transactions")
                }
                .padding()
                .background(Color(hex: "#94A684"))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            Spacer()
        }
    }
}

#Preview {
    AllTransactionsView(showAllTransactions: .constant(false))
}
