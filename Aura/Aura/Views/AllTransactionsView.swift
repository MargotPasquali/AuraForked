//
//  AllTransactionsView.swift
//  Aura
//
//  Created by Margot Pasquali on 16/07/2024.
//

import SwiftUI

// MARK: - AllTransactionsView

/// Vue permettant à l'utilisateur d'afficher plus ou moins de transactions.
///
/// Cette vue contient un bouton qui permet de basculer entre l'affichage complet des transactions et l'affichage limité.
struct AllTransactionsView: View {
    
    // MARK: - Binding Properties
    
    @Binding var showAllTransactions: Bool
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                // Basculer l'affichage des transactions
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

// MARK: - Preview

#Preview {
    AllTransactionsView(showAllTransactions: .constant(false))
}
