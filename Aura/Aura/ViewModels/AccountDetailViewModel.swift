//
//  AccountDetailViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

// MARK: - AccountDetailViewModel

/// ViewModel responsable de la gestion des détails du compte.
///
/// Cette classe gère la récupération et la mise à jour des informations de compte, telles que le solde total et les transactions récentes.
class AccountDetailViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var totalAmount: Double = 0
    @Published var recentTransactions: [Transaction] = []
    
    // MARK: - Dependencies
    
    var accountService: AccountService
    
    // MARK: - Init
    
    /// Initialise le ViewModel avec un service de compte.
    ///
    /// Récupère immédiatement les détails du compte lors de l'initialisation.
    init(accountService: AccountService = RemoteAccountService()) {
        self.accountService = accountService
        Task {
            await fetchAccountDetails()
        }
    }
    
    // MARK: - Fetch Account Details
    
    /// Récupère les détails du compte et met à jour les propriétés publiées.
    ///
    /// Cette méthode est exécutée de manière asynchrone pour appeler le service de compte.
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

