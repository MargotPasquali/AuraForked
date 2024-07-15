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
    
    let onLoginSucceed: (() -> ())
    
    init(_ callback: @escaping () -> ()) {
        self.onLoginSucceed = callback
    }
    
    func login() {
        isLoading = true
        errorMessage = nil

        AuthService.shared.getAuth(username: username, password: password) { [weak self] data, error in
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
            AuthService.shared.logAccount { [weak self] data, error in
                guard let self = self else { return }
                
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("Error in logAccount: \(error.localizedDescription)") // Debug
                    return
                }

                if let data = data {
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
