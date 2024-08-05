//
//  AccountDetailViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class AccountDetailViewModel: ObservableObject {
    @Published var totalAmount: Double = 0
    @Published var recentTransactions: [Transaction] = []
    
    var accountService: AccountService
    
    init(accountService: AccountService = RemoteAccountService()) {
        self.accountService = accountService
        Task {
            await fetchAccountDetails()
        }
    }
    
    func fetchAccountDetails() async {
        do {
            let accountDetail = try await accountService.logAccount()
            DispatchQueue.main.async {
                self.totalAmount = accountDetail.currentBalance
                self.recentTransactions = accountDetail.transactions
            }
        } catch {
            DispatchQueue.main.async {
                print("Error fetching account details: \(error.localizedDescription)")
                self.totalAmount = 0
                self.recentTransactions = []
            }
        }
    }
}

