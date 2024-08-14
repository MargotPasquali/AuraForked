//
//  MockProtocol.swift
//  AuraTests
//
//  Created by Margot Pasquali on 31/07/2024.
//

import Foundation

// MARK: - MockProtocol

/// Classe de simulation pour `URLProtocol`.
///
/// Cette classe permet de simuler les réponses réseau pour les tests unitaires, en interceptant les requêtes réseau
/// et en fournissant des réponses personnalisées ou des erreurs simulées.
class MockProtocol: URLProtocol {
    
    // MARK: - Static Properties
    
    /// Un gestionnaire de requêtes personnalisé qui retourne une réponse HTTP et des données.
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    /// Une erreur simulée pour les tests.
    static var error: Error?
    
    // MARK: - URLProtocol Overrides
    
    /// Indique si ce protocole peut gérer la requête donnée.
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    /// Retourne la requête canonique pour une requête donnée.
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    /// Démarre le traitement de la requête.
    ///
    /// Cette méthode envoie une réponse simulée ou une erreur à l'objet client en fonction du `requestHandler` ou de l'erreur définie.
    override func startLoading() {
        if let error = MockProtocol.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        
        guard let handler = MockProtocol.requestHandler else {
            fatalError("Handler is unavailable.")
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    /// Arrête le traitement de la requête.
    override func stopLoading() {}
}
