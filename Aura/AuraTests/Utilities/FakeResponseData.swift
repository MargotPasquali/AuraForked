//
//  FakeResponseData.swift
//  AuraTests
//
//  Created by Margot Pasquali on 29/07/2024.
//

import Foundation

// MARK: - FakeResponseData

/// Classe contenant des données de réponse simulées pour les tests.
///
/// Cette classe fournit des réponses HTTP, des erreurs, et des données de réponse JSON simulées,
/// permettant de tester différents scénarios sans effectuer de véritables requêtes réseau.
class FakeResponseData {
    
    // MARK: - Simulated HTTP Responses
    
    /// Réponse HTTP simulée pour une requête réussie.
    static let responseOk = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    
    /// Réponse HTTP simulée pour une erreur interne du serveur.
    static let responseKo = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/")!, statusCode: 500, httpVersion: nil, headerFields: nil)!
    
    /// Réponse HTTP simulée pour une erreur de serveur.
    static let responseServerError = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/")!, statusCode: 500, httpVersion: nil, headerFields: nil)!
    
    /// Réponse HTTP simulée pour une requête avec un jeton invalide.
    static let responseWithInvalidToken = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/")!, statusCode: 401, httpVersion: nil, headerFields: nil)!
    
    // MARK: - Simulated Error
    
    /// Classe représentant une erreur d'authentification simulée.
    class AuthError: Error {}
    
    /// Erreur simulée utilisée pour les tests.
    static let error = AuthError()
    
    // MARK: - Simulated Correct Data
    
    /// Données de réponse correctes simulées pour une authentification réussie.
    static var authCorrectData: Data {
        let json = """
        {
            "token": "FB24D136-C228-491D-AB30-FDFD97009D19"
        }
        """
        return Data(json.utf8)
    }
    
    /// Données de réponse incorrectes simulées pour une authentification échouée (jeton invalide).
    static var authIncorrectData: Data {
        let json = """
        {
            "token": "INVALID_TOKEN"
        }
        """
        return Data(json.utf8)
    }
    
    /// Données de réponse correctes simulées pour la récupération des détails du compte.
    static var logAccountCorrectData: Data {
        let json = """
        {
            "currentBalance": 1234.56,
            "transactions": [
                {"label": "Transaction 1", "value": 100.0},
                {"label": "Transaction 2", "value": -50.0}
            ]
        }
        """
        return Data(json.utf8)
    }
    
    // MARK: - Simulated Incorrect Data
    
    /// Données de réponse incorrectes simulées (JSON incorrect).
    static let incorrectData = "incorrect json".data(using: .utf8)!
}
