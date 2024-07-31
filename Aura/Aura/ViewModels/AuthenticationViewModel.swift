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
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.authenticate(username: username, password: password)
        } catch {
            isLoading = false
            throw AuthenticationViewModelError.authenticationFailed
        }
        
        isLoading = false
    }

    @MainActor
    func retrieveAccountDetails() async throws {
        print("Retrieving account details") // Debug
        
        isLoading = true
        errorMessage = nil
        
        do {
            let accountDetails = try await accountService.logAccount()
            callback(true)
        } catch {
            isLoading = false
            throw AuthenticationViewModelError.missingAccountDetails
        }
        
        isLoading = false
    }

    @MainActor
    func login() async throws {
        do {
            try await performAuthentication()
            try await retrieveAccountDetails()
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
}
