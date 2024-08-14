//
//  AccountDetailView.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import SwiftUI

// MARK: - AccountDetailView

/// Vue affichant les détails du compte de l'utilisateur.
///
/// Cette vue montre le solde total de l'utilisateur ainsi que ses transactions récentes.
struct AccountDetailView: View {
    
    // MARK: - Observed Object
    
    @ObservedObject var viewModel: AccountDetailViewModel
    @State private var showAllTransactions = false
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            
            // MARK: - Header: Total Amount
            
            // En-tête affichant le solde total
            VStack(spacing: 10) {
                Text("Your Balance")
                    .font(.headline)
                Text(viewModel.totalAmount, format: .currency(code: "EUR"))
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(Color(hex: "#94A684")) // Utilisation de la couleur verte fournie
                Image(systemName: "eurosign.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                    .foregroundColor(Color(hex: "#94A684"))
            }
            .padding(.top)
            
            // MARK: - Transactions List
            
            // ScrollView pour afficher toutes les transactions
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Transactions")
                        .font(.headline)
                        .padding([.horizontal])
                    
                    // Affiche uniquement les trois premières transactions si showAllTransactions est faux
                    ForEach(showAllTransactions ? viewModel.recentTransactions : Array(viewModel.recentTransactions.prefix(3)), id: \.label) { transaction in
                        HStack {
                            Image(systemName: transaction.value >= 0 ? "arrow.up.right.circle.fill" : "arrow.down.left.circle.fill")
                                .foregroundColor(transaction.value >= 0 ? .green : .red)
                            Text(transaction.label)
                            Spacer()
                            Text(String(format: "€%.2f", transaction.value))
                                .fontWeight(.bold)
                                .foregroundColor(transaction.value >= 0 ? .green : .red)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .padding([.horizontal])
                    }
                    
                    // Bouton pour voir plus/moins de transactions
                    if viewModel.recentTransactions.count > 3 {
                        AllTransactionsView(showAllTransactions: $showAllTransactions)
                            .padding([.horizontal, .bottom])
                    }
                }
            }
            
            Spacer()
        }
        .onAppear {
            // Charger les détails du compte à l'apparition de la vue
            Task {
                await viewModel.fetchAccountDetails()
            }
        }
        .onTapGesture {
            self.endEditing(true)  // Cela permettra de cacher le clavier en tapant à l'extérieur
        }
    }
}

// MARK: - Preview

#Preview {
    AccountDetailView(viewModel: AccountDetailViewModel())
}
