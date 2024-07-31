//
//  FakeResponseData.swift
//  AuraTests
//
//  Created by Margot Pasquali on 29/07/2024.
//

import Foundation

class FakeResponseData {
    // Réponses HTTP simulées
    static let responseOk = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    static let responseKo = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/")!, statusCode: 500, httpVersion: nil, headerFields: nil)!
    
    // Erreur simulée
    class AuthError: Error {}
    static let error = AuthError()
    
    // Données de réponse correctes simulées à partir d'un fichier JSON
    static var authCorrectData: Data {
        let json = """
        {
            "token": "FB24D136-C228-491D-AB30-FDFD97009D19"
        }
        """
        return Data(json.utf8)
    }
    
    static var authIncorrectData: Data {
        let json = """
        {
            "token": "INVALID_TOKEN"
        }
        """
        return Data(json.utf8)
    }
    
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
    
    // Données de réponse incorrectes simulées
    static let incorrectData = "erreur".data(using: .utf8)!
}
