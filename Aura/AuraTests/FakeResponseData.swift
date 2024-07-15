//
//  FakeResponseData.swift
//  AuraTests
//
//  Created by Margot Pasquali on 15/07/2024.
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
        let bundle = Bundle(for: FakeResponseData.self)
        guard let url = bundle.url(forResource: "Auth", withExtension: "json") else {
            fatalError("Auth.json file not found")
        }
        return try! Data(contentsOf: url)
    }
    
    // Données de réponse incorrectes simulées
    static let authIncorrectData = "erreur".data(using: .utf8)!
}
