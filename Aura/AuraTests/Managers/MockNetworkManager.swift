//
//  MockNetworkManager.swift
//  AuraTests
//
//  Created by Margot Pasquali on 08/08/2024.
//

import Foundation
@testable import Aura

// MARK: - MockNetworkManager

/// Classe simulée pour tester les fonctionnalités réseau.
///
/// Cette classe implémente le protocole `NetworkManagerProtocol` et permet de simuler des réponses réseau pour les tests unitaires.
final class MockNetworkManager: NetworkManagerProtocol {
    
    // MARK: - Mock Properties
    
    var token: String?
    var responseData: Data?
    var response: HTTPURLResponse?
    var error: Error?
    
    // MARK: - NetworkManagerProtocol Methods
    
    /// Simule la récupération des données pour une requête réseau.
    ///
    /// - Parameters:
    ///   - request: La requête réseau à exécuter.
    ///   - authenticatedRequest: Indique si la requête nécessite une authentification.
    /// - Returns: Une paire de données et de réponse HTTP simulées.
    /// - Throws: Une erreur simulée si nécessaire.
    func data(for request: URLRequest, authenticatedRequest: Bool) async throws -> (Data, HTTPURLResponse) {
        if let error = error {
            throw AuthServiceError.networkError(error)
        }
        
        guard let response = response, let responseData = responseData else {
            throw AuthServiceError.invalidResponse
        }
        
        return (responseData, response)
    }
    
    /// Simule l'enregistrement d'un jeton d'authentification.
    ///
    /// - Parameter token: Le jeton d'authentification à enregistrer.
    func set(token: String) {
        self.token = token
    }
}
