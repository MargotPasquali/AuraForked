//
//  MoneyTransferViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class MoneyTransferViewModel: ObservableObject {
    
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

    @Published var recipient: String = ""
    @Published var amount: String = ""
    @Published var transferMessage: String = ""
    
    var accountDetailViewModel: AccountDetailViewModel
    var accountService: AccountService
    
    init(accountDetailViewModel: AccountDetailViewModel, accountService: AccountService = RemoteAccountService()) {
        self.accountDetailViewModel = accountDetailViewModel
        self.accountService = accountService
    }
    
    static func validateEmail(_ email: String) -> Bool {
        let emailRegEx = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    static func validatePhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneRegEx = "^\\+?[0-9]{1,4}[\\s-]?[0-9]{1,3}([\\s-]?[0-9]{1,4}){1,4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phoneTest.evaluate(with: phoneNumber)
    }
    
    static func validateRecipient(_ recipient: String) -> Bool {
        return validateEmail(recipient) || validatePhoneNumber(recipient)
    }
    
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
