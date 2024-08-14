//
//  MockServices.swift
//  AuraTests
//
//  Created by Margot Pasquali on 05/08/2024.
//

import Foundation
@testable import Aura

// MARK: - MockAuthService

/// Service d'authentification simulé pour les tests unitaires.
///
/// Cette classe implémente le protocole `AuthService` et permet de simuler les réponses d'authentification,
/// en retournant soit une réponse d'authentification correcte, soit une erreur.
final class MockAuthService: AuthService {
    
    // MARK: - Properties
    
    var networkManager: NetworkManagerProtocol
    
    var authResponse: AuthenticationResponse?
    var error: AuthServiceError?
    
    // MARK: - Initializer
    
    required init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    // MARK: - AuthService Methods
    
    /// Simule le processus d'authentification.
    ///
    /// Si une erreur est définie, elle est lancée. Sinon, si une réponse d'authentification est définie,
    /// le jeton est enregistré via le `networkManager`. Si aucune réponse n'est définie, une erreur inconnue est lancée.
    func authenticate(username: String, password: String) async throws {
        if let error = error {
            throw error
        }
        
        if let authResponse = authResponse {
            networkManager.set(token: authResponse.token)
        } else {
            throw AuthServiceError.unknown
        }
    }
}

// MARK: - MockAccountService

/// Service de gestion de compte simulé pour les tests unitaires.
///
/// Cette classe implémente le protocole `AccountService` et permet de simuler les réponses
/// liées à la récupération des détails du compte et à la création de transferts.
final class MockAccountService: AccountService {
    
    // MARK: - Properties
    
    var accountServiceError: AccountServiceError?
    
    var accountDetails: AccountDetail = AccountDetail(currentBalance: 1234.56, transactions: [])
    
    // MARK: - AccountService Methods
    
    /// Simule la récupération des détails du compte.
    ///
    /// Si une erreur de service est définie, elle est lancée. Sinon, les détails du compte simulés sont retournés.
    func logAccount() async throws -> AccountDetail {
        if let accountServiceError = accountServiceError {
            throw accountServiceError
        } else {
            return accountDetails
        }
    }
    
    /// Simule la création d'un transfert.
    ///
    /// Si une erreur de service est définie, elle est lancée.
    func createTransfer(recipient: String, amount: Float) async throws {
        if let accountServiceError = accountServiceError {
            throw accountServiceError
        }
    }
    
    // MARK: - Setup
    
    /// Réinitialise les détails du compte à leur valeur par défaut.
    func setup() {
        accountDetails = AccountDetail(currentBalance: 1234.56, transactions: [])
    }
}
