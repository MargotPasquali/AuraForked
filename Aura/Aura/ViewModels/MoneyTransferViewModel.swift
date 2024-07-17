//
//  MoneyTransferViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class MoneyTransferViewModel: ObservableObject {
    @Published var recipient: String = ""
    @Published var amount: String = ""
    @Published var transferMessage: String = ""
    
    var accountDetailViewModel: AccountDetailViewModel

    init(accountDetailViewModel: AccountDetailViewModel) {
        self.accountDetailViewModel = accountDetailViewModel
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

    func sendMoney() {
        guard !recipient.isEmpty, !amount.isEmpty, let amountValue = Float(amount) else {
            transferMessage = "Please enter a valid recipient and amount."
            return
        }
        
        guard MoneyTransferViewModel.validateRecipient(recipient) else {
            transferMessage = "Please enter a valid email or phone number."
            return
        }
        
        AuthService.shared.createTransfer(recipient: recipient, amount: amountValue) { [weak self] (error: Error?) in
            guard let self = self else { return }
            
            if let error = error {
                self.transferMessage = "Transfer failed: \(error.localizedDescription)"
            } else {
                self.transferMessage = "Successfully transferred \(self.amount) to \(self.recipient)"
                self.accountDetailViewModel.fetchAccountDetails()
            }
        }
    }
}
