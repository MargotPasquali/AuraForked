//
//  AuthenticationViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation
import SwiftUI

protocol AuthenticationViewModelDelegate: AnyObject {
    func authenticationFailed(message: String)
    func authenticationSuccessful()
}

class AuthenticationViewModel: ObservableObject {
    
    enum AuthenticationViewModelError: Error {
        case authenticationFailed
    }
    
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    @Published var destinationView: AnyView? = nil
    
    weak var delegate: AuthenticationViewModelDelegate?
    var authService: AuthService
    
    init(authService: AuthService = AuthService.shared, callback: @escaping () -> () = {}) {
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
    
    func login() async {
        print("Trying to login with username: \(username) and password: \(password)") // Debug
        
        guard AuthenticationViewModel.validateEmail(username) else {
            errorMessage = "Invalid email address"
            print("Invalid email address") // Debug
            delegate?.authenticationFailed(message: "Invalid email address")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Authenticate
        Task {
            do {
                try await authService.authenticate(username: username, password: password)
            } catch {
                delegate?.authenticationFailed(message: "Authentication failed")
                return
            }
        }
        
        // Retrieve account details
        Task {
            do {
                let accountDetails = try await authService.logAccount()
                isAuthenticated = true
                delegate?.authenticationSuccessful()
            } catch {
                delegate?.authenticationFailed(message: "Failed to retrieve account details")
            }
            
            isLoading = false
        }}
}
