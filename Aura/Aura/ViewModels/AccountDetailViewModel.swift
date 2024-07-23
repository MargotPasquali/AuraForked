//
//  AccountDetailViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class AccountDetailViewModel: ObservableObject {
    @Published var totalAmount: String = ""
    @Published var recentTransactions: [Transaction] = []
    
    var authService: AuthService
    
    init(authService: AuthService = AuthService.shared) {
        self.authService = authService
        Task {
            await fetchAccountDetails()
        }
    }
    
    func fetchAccountDetails() async {
        do {
            let accountDetail = try await authService.logAccount()
            self.totalAmount = String(format: "€%.2f", accountDetail.currentBalance)
            self.recentTransactions = accountDetail.transactions
        } catch {
            print("Error fetching account details: \(error.localizedDescription)")
        }
    }
}
