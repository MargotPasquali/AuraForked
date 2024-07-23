//
//  AccountDetailViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

final class AccountDetailViewModel: ObservableObject {
    @Published var totalAmount: Double = 0
    @Published var recentTransactions: [Transaction] = []
    
    var authService: AuthService
    
    init(authService: AuthService = AuthService.shared) {
        self.authService = authService
        Task {
            await fetchAccountDetails()
        }
    }
    
    @MainActor
    func fetchAccountDetails() async {
        do {
            let accountDetail = try await authService.logAccount()

            totalAmount = accountDetail.currentBalance

            recentTransactions = accountDetail.transactions
        } catch {
            print("Error fetching account details: \(error.localizedDescription)")
        }
    }
}
