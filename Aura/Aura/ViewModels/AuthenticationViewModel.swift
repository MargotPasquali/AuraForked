//
//  AuthenticationViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import SwiftUI

final class AuthenticationViewModel: ObservableObject {

    enum AuthenticationViewModelError: Error {
        case authenticationFailed
    }
    
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let authService: AuthService
    private let callback: () -> Void

    init(authService: AuthService = AuthService.shared, callback: @escaping () -> Void = {}) {
        self.authService = authService
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
    func login() async {
        print("Trying to login with username: \(username) and password: \(password)") // Debug

        guard AuthenticationViewModel.validateEmail(username) else {
            errorMessage = "Invalid email address"
            return
        }

        isLoading = true
        errorMessage = nil

        // Authenticate
        do {
            try await authService.authenticate(username: username, password: password)
        } catch {
            errorMessage = "Authentication failed"
            return
        }
        
        callback()

        isLoading = false
    }
}
