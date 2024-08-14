//
//  MoneyTransferViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

// MARK: - MoneyTransferViewModel

/// ViewModel responsable de la gestion des transferts d'argent.
///
/// Cette classe gère la validation des informations du destinataire, le montant du transfert, et la communication avec le service de compte pour exécuter le transfert.
class MoneyTransferViewModel: ObservableObject {
    
    // MARK: - MoneyTransferError
    
    /// Enumération des erreurs spécifiques au transfert d'argent.
    ///
    /// Fournit des descriptions localisées pour les différentes erreurs qui peuvent survenir durant le processus de transfert.
    enum MoneyTransferError: Error, LocalizedError {
        case transferFailed
        case invalidRecipientOrAmount
        case emptyField
        
        var errorDescription: String? {
            switch self {
            case .transferFailed:
                return "Transfer failed"
            case .invalidRecipientOrAmount:
                return "Invalid recipient or amount"
            case .emptyField:
                return "Fields cannot be empty"
            }
        }
    }
    
    // MARK: - Published Properties
    
    @Published var recipient: String = ""
    @Published var amount: String = ""
    @Published var transferMessage: String = ""
    
    // MARK: - Dependencies
    
    var accountDetailViewModel: AccountDetailViewModel
    var accountService: AccountService
    
    // MARK: - Init
    
    /// Initialise le ViewModel avec les ViewModels de compte et le service de compte.
    init(accountDetailViewModel: AccountDetailViewModel, accountService: AccountService = RemoteAccountService()) {
        self.accountDetailViewModel = accountDetailViewModel
        self.accountService = accountService
    }
    
    // MARK: - Validation Methods
    
    /// Valide si l'adresse email est correcte.
    ///
    /// - Parameter email: L'adresse email à valider.
    /// - Returns: Un booléen indiquant si l'email est valide.
    static func validateEmail(_ email: String) -> Bool {
        let emailRegEx = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    /// Valide si le numéro de téléphone est correct.
    ///
    /// - Parameter phoneNumber: Le numéro de téléphone à valider.
    /// - Returns: Un booléen indiquant si le numéro de téléphone est valide.
    static func validatePhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneRegEx = "^\\+?[0-9]{1,4}[\\s-]?[0-9]{1,3}([\\s-]?[0-9]{1,4}){1,4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phoneTest.evaluate(with: phoneNumber)
    }
    
    /// Valide si le destinataire est valide (email ou numéro de téléphone).
    ///
    /// - Parameter recipient: Le destinataire à valider.
    /// - Returns: Un booléen indiquant si le destinataire est valide.
    static func validateRecipient(_ recipient: String) -> Bool {
        return validateEmail(recipient) || validatePhoneNumber(recipient)
    }
    
    // MARK: - Money Transfer
    
    /// Envoie de l'argent au destinataire spécifié.
    ///
    /// Cette méthode vérifie les champs du formulaire, valide le destinataire, puis tente d'effectuer un transfert d'argent via le service de compte.
    @MainActor
    func sendMoney() async throws {
        print("sendMoney called with recipient: \(recipient), amount: \(amount)")
        guard !recipient.isEmpty, !amount.isEmpty, let amountValue = Float(amount) else {
            DispatchQueue.main.async {
                self.transferMessage = "Fields cannot be empty"
            }
            print("sendMoney failed due to empty fields")
            throw MoneyTransferError.emptyField
        }
        
        guard MoneyTransferViewModel.validateRecipient(recipient) else {
            DispatchQueue.main.async {
                self.transferMessage = "Invalid recipient or amount"
            }
            print("sendMoney failed due to invalid recipient or amount")
            throw MoneyTransferError.invalidRecipientOrAmount
        }
        
        do {
            try await accountService.createTransfer(recipient: recipient, amount: amountValue)
            DispatchQueue.main.async {
                self.transferMessage = "Successfully transferred \(self.amount) to \(self.recipient)"
            }
            print("sendMoney succeeded")
            await accountDetailViewModel.fetchAccountDetails()
        } catch {
            DispatchQueue.main.async {
                self.transferMessage = "Transfer failed: \(error.localizedDescription)"
            }
            print("sendMoney failed with error: \(error)")
            throw MoneyTransferError.transferFailed
        }
    }
}
