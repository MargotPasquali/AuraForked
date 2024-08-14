//
//  AuthenticationViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation
import SwiftUI

// MARK: - AuthenticationViewModel

/// ViewModel responsable de la gestion de l'authentification et de la récupération des détails du compte.
///
/// Cette classe gère l'interaction avec les services d'authentification et de compte, ainsi que l'état de l'interface utilisateur durant ces processus.
class AuthenticationViewModel: ObservableObject {
    
    // MARK: - Enums
    
    /// Enumération des erreurs spécifiques au `AuthenticationViewModel`.
    enum AuthenticationViewModelError: Error {
        case authenticationFailed
        case missingAccountDetails
    }
    
    // MARK: - Published Properties
    
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    var authService: AuthService
    var accountService: AccountService
    
    // MARK: - Private Properties
    
    private let callback: (Bool) -> Void
    
    // MARK: - Init
    
    /// Initialise le ViewModel avec les services d'authentification et de gestion de compte.
    init(authService: AuthService = RemoteAuthService(), accountService: AccountService = RemoteAccountService(), callback: @escaping (Bool) -> Void = { _ in }) {
        self.authService = authService
        self.accountService = accountService
        self.callback = callback
    }
    
    // MARK: - Validation Methods
    
    /// Valide l'adresse email fournie en utilisant une expression régulière.
    ///
    /// - Parameter email: L'adresse email à valider.
    /// - Returns: Un booléen indiquant si l'email est valide.
    static func validateEmail(_ email: String) -> Bool {
        let emailRegEx = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let range = NSRange(location: 0, length: email.utf16.count)
        let regex = try! NSRegularExpression(pattern: emailRegEx)
        
        // Vérifie si l'email correspond au regex et n'a pas de points consécutifs
        let match = regex.firstMatch(in: email, options: [], range: range)
        
        return match != nil && !email.contains("..")
    }
    
    // MARK: - Authentication Methods
    
    /// Effectue l'authentification de l'utilisateur.
    @MainActor
    func performAuthentication() async throws {
        print("Trying to authenticate with username: \(username) and password: \(password)") // Debug
        
        guard AuthenticationViewModel.validateEmail(username), !password.isEmpty else {
            throw AuthenticationViewModelError.authenticationFailed
        }
        
        errorMessage = nil
        
        do {
            try await authService.authenticate(username: username, password: password)
        } catch {
            isLoading = false
            throw AuthenticationViewModelError.authenticationFailed
        }
    }
    
    // MARK: - Account Details Methods
    
    /// Récupère les détails du compte de l'utilisateur après une authentification réussie.
    @MainActor
    func retrieveAccountDetails() async throws {
        print("Retrieving account details") // Debug
        
        errorMessage = nil
        
        do {
            let accountDetails = try await accountService.logAccount()
            print("Account details retrieved: \(accountDetails)") // Debug
            callback(true)
        } catch {
            isLoading = false
            print("Failed to retrieve account details with error: \(error.localizedDescription)") // Debug
            throw AuthenticationViewModelError.missingAccountDetails
        }
    }
    
    // MARK: - Login Process
    
    /// Processus de connexion complet, incluant l'authentification et la récupération des détails du compte.
    @MainActor
    func login() async throws {
        print("Starting login process") // Debug
        
        do {
            isLoading = true
            
            try await performAuthentication()
            print("Authentication step completed successfully") // Debug
            try await retrieveAccountDetails()
            print("Account details retrieval step completed successfully") // Debug
            
            isLoading = false
        } catch {
            isLoading = false
            print("Login failed at \(error) with error: \(error.localizedDescription)") // Debug
            errorMessage = error.localizedDescription
            throw error
        }
    }
}
