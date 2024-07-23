//
//  AccountDetailView.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import SwiftUI

struct AccountDetailView: View {
    @ObservedObject var viewModel: AccountDetailViewModel
    @State private var showAllTransactions = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Large Header displaying total amount
            VStack(spacing: 10) {
                Text("Your Balance")
                    .font(.headline)
                Text(viewModel.totalAmount)
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(Color(hex: "#94A684")) // Using the green color you provided
                Image(systemName: "eurosign.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                    .foregroundColor(Color(hex: "#94A684"))
            }
            .padding(.top)
            
            // ScrollView for all transactions
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Transactions")
                        .font(.headline)
                        .padding([.horizontal])
                    
                    // Display only the first three transactions if showAllTransactions is false
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
                    
                    // Button to see more/less transactions
                    if viewModel.recentTransactions.count > 3 {
                        AllTransactionsView(showAllTransactions: $showAllTransactions)
                            .padding([.horizontal, .bottom])
                    }
                }
            }
            
            Spacer()
        }
        .onAppear {
            Task {
                await viewModel.fetchAccountDetails()
            }
        }
        .onTapGesture {
            self.endEditing(true)  // This will dismiss the keyboard when tapping outside
        }
    }
}

#Preview {
    AccountDetailView(viewModel: AccountDetailViewModel())
}

