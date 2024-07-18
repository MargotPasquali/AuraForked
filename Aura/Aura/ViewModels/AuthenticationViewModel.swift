//
//  AuthenticationViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation
import SwiftUI

class AuthenticationViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    @Published var destinationView: AnyView? = nil
    
    var onLoginSucceed: (() -> ())
    var authService: AuthService
    
    init(authService: AuthService = AuthService.shared, callback: @escaping () -> () = {}) {
        self.authService = authService
        self.onLoginSucceed = callback
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

    func login() {
        print("Trying to login with username: \(username) and password: \(password)") // Debug
        
        guard AuthenticationViewModel.validateEmail(username) else {
            errorMessage = "Invalid email address"
            print("Invalid email address") // Debug
            return
        }
        
        isLoading = true
        errorMessage = nil

        authService.getAuth(username: username, password: password) { [weak self] data, error in
            guard let self = self else { return }
            
            if let error = error {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                print("Error in getAuth: \(error.localizedDescription)") // Debug
                return
            }

            guard data != nil else {
                self.isLoading = false
                self.errorMessage = "Unknown error"
                print("Error in getAuth: Unknown error") // Debug
                return
            }

            // Maintenant que nous avons obtenu le token, nous appelons logAccount
            self.authService.logAccount { [weak self] (accountDetail: AccountDetail?, error: Error?) in
                guard let self = self else { return }
                
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("Error in logAccount: \(error.localizedDescription)") // Debug
                    return
                }

                if let accountDetail = accountDetail {
                    // Si logAccount réussit, nous considérons l'utilisateur comme authentifié
                    self.isAuthenticated = true
                    print("Authentication successful") // Debug
                    self.destinationView = AnyView(AccountDetailView(viewModel: AccountDetailViewModel()))
                    self.onLoginSucceed()
                } else {
                    // Sinon, afficher un message d'erreur
                    self.errorMessage = "Authentication failed"
                    print("Error in logAccount: Authentication failed") // Debug
                }
            }
        }
    }
}
