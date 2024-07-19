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
    
    init() {
        fetchAccountDetails()
    }
    
    func fetchAccountDetails() {
//        AuthService.shared.logAccount { [weak self] (accountDetail: AccountDetail?, error: Error?) in
//            guard let self = self else { return }
//            
//            if let error = error {
//                print("Error fetching account details: \(error.localizedDescription)")
//                return
//            }
//            
//            if let accountDetail = accountDetail {
//                self.totalAmount = String(format: "€%.2f", accountDetail.currentBalance)
//                self.recentTransactions = accountDetail.transactions
//            }
//        }
    }
}
