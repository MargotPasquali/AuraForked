//
//  AuthenticationViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation
import SwiftUI

class AuthenticationViewModel: ObservableObject {
    
    enum AuthenticationViewModelError: Error {
        case authenticationFailed
        case missingAccountDetails
    }
    
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    var authService: AuthService
    var accountService: AccountService
    
    private let callback: (Bool) -> Void
    
    init(authService: AuthService = RemoteAuthService(), accountService: AccountService = RemoteAccountService(), callback: @escaping (Bool) -> Void = { _ in }) {
        self.authService = authService
        self.accountService = accountService
        self.callback = callback
    }
    
    static func validateEmail(_ email: String) -> Bool {
        let emailRegEx = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
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
