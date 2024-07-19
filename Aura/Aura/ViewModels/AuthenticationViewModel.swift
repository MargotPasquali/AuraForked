//
//  AuthenticationViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

protocol AuthenticationViewModelDelegate: AnyObject {

    func authenticationFailed(message: String)

    func authenticationSuccessfull()
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

    weak var delegate: AuthenticationViewModelDelegate?

    var authService: AuthService

    init(authService: AuthService = .shared) {
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
            return
        }
        
        isLoading = true
        errorMessage = nil

        // Authenticate
        do {
            try await authService.authenticate(username: username, password: password)
        } catch {
            delegate?.authenticationFailed(message: "Authentication failed")
            return
        }

        // Retrieve account details
        do {
            let accountDetails = try await authService.login()
        } catch {
            delegate?.authenticationFailed(message: "Failed to retrieve account details")
            return
        }

        isAuthenticated = true

        delegate?.authenticationSuccessfull()
    }
}
