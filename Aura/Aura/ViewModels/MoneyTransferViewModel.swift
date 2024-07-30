//
//  MoneyTransferViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class MoneyTransferViewModel: ObservableObject {
    
    enum MoneyTransferError: Error {
        case transferFailed
        case invalidRecipientOrAmount
        case emptyField
    }
    @Published var recipient: String = ""
    @Published var amount: String = ""
    @Published var transferMessage: String = ""
    
    var accountDetailViewModel: AccountDetailViewModel
    var authService: AuthService
    
    
    init(accountDetailViewModel: AccountDetailViewModel, authService: AuthService = RemoteAuthService()) {
        self.accountDetailViewModel = accountDetailViewModel
        self.authService = authService
    }
    
    static func validateEmail(_ email: String) -> Bool {
        let emailRegEx = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        let range = NSRange(location: 0, length: email.utf16.count)
        let regex = try! NSRegularExpression(pattern: emailRegEx)
        
        // Check if the email matches the regex
        let match = regex.firstMatch(in: email, options: [], range: range)
        
        // Ensure no consecutive dots are present
        if match != nil && !email.contains("..") {
            return true
        } else {
            return false
        }
    }
    
    static func validatePhoneNumber(_ phoneNumber: String) -> Bool {
        // More flexible regex to match various phone number formats
        let phoneRegEx = "^\\+?[0-9]{1,4}[\\s-]?[0-9]{1,3}([\\s-]?[0-9]{1,4}){1,4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        let result = phoneTest.evaluate(with: phoneNumber)
        print("Validating phone number: \(phoneNumber), Result: \(result)")
        return result
    }
    
    static func validateRecipient(_ recipient: String) -> Bool {
        let isValidEmail = validateEmail(recipient)
        let isValidPhone = validatePhoneNumber(recipient)
        print("Validating recipient: \(recipient), isValidEmail: \(isValidEmail), isValidPhone: \(isValidPhone)")
        return isValidEmail || isValidPhone
    }
    
    func sendMoney() async throws{
        guard !recipient.isEmpty, !amount.isEmpty, let amountValue = Float(amount) else {
            throw MoneyTransferError.emptyField
            return
        }
        
        guard MoneyTransferViewModel.validateRecipient(recipient) else {
            throw MoneyTransferError.invalidRecipientOrAmount
            return
        }
        
        do {
            try await authService.createTransfer(recipient: recipient, amount: amountValue)
            DispatchQueue.main.async {
                self.transferMessage = "Successfully transferred \(self.amount) to \(self.recipient)"
            }
            await accountDetailViewModel.fetchAccountDetails()
        } catch {
            DispatchQueue.main.async {
                self.transferMessage = "Transfer failed: \(error.localizedDescription)"
            }
        }
    }
}
