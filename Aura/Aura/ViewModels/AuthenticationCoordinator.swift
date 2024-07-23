//
//  AuthenticationCoordinator.swift
//  Aura
//
//  Created by Margot Pasquali on 23/07/2024.
//

import Foundation
import SwiftUI

class AuthenticationCoordinator: AuthenticationViewModelDelegate, ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?
    @Published var destinationView: AnyView?
    
    func authenticationFailed(message: String) {
        errorMessage = message
    }
    
    func authenticationSuccessful() {
        isAuthenticated = true
        destinationView = AnyView(AccountDetailView(viewModel: AccountDetailViewModel()))
    }
}
