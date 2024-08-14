//
//  AccountService.swift
//  Aura
//
//  Created by Margot Pasquali on 30/07/2024.
//

import Foundation

// MARK: - AccountService Protocol

/// Protocole définissant les méthodes pour la gestion des comptes.
///
/// Ce protocole inclut des méthodes pour se connecter à un compte et créer un transfert.
protocol AccountService {
    func logAccount() async throws -> AccountDetail
    func createTransfer(recipient: String, amount: Float) async throws
}

// MARK: - AccountServiceError

/// Enumération des erreurs possibles liées au service de gestion de compte.
enum AccountServiceError: Error {
    case invalidCredentials
    case invalidResponse
    case unauthorized
    case missingToken
    case unknown
    case decodingError(DecodingError)
    case networkError(Error)
    case serverError
}

// MARK: - RemoteAccountService

/// Implémentation distante du service de gestion de compte.
///
/// Cette classe utilise `NetworkManagerProtocol` pour effectuer des requêtes réseau sécurisées.
final class RemoteAccountService: AccountService {
    
    // MARK: - Properties
    
    private static let url = URL(string: "http://127.0.0.1:8080/")!
    private var task: URLSessionDataTask?
    private let networkManager: NetworkManagerProtocol
    
    // MARK: - Init
    
    /// Initialisation du service avec un `NetworkManagerProtocol`.
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        print("Initializing RemoteAccountService")
        self.networkManager = networkManager
    }
    
    // MARK: - Account Management
    
    /// Récupère les détails du compte en se connectant via une requête réseau.
    func logAccount() async throws -> AccountDetail {
        print("logAccount called")
        
        var request = URLRequest(url: RemoteAccountService.url.appendingPathComponent("account"))
        
        do {
            let (data, response) = try await networkManager.data(for: request, authenticatedRequest: true)
            print("Received response: \(response.statusCode)")
            print("Received data: \(String(data: data, encoding: .utf8) ?? "No data")")
            
            guard response.statusCode == 200 else {
                print("Non-200 status code received: \(response.statusCode)")
                if response.statusCode == 401 {
                    throw AuthServiceError.unauthorized
                } else if response.statusCode >= 500 {
                    throw AuthServiceError.serverError
                } else {
                    throw AuthServiceError.invalidResponse
                }
            }
            
            do {
                let accountDetail = try JSONDecoder().decode(AccountDetail.self, from: data)
                print("Decoded account detail: \(accountDetail)")
                return accountDetail
            } catch let decodingError as DecodingError {
                print("Caught DecodingError: \(decodingError)")
                throw AuthServiceError.decodingError(decodingError)
            }
        } catch {
            print("Caught error in logAccount: \(error)")
            throw error
        }
    }
    
    /// Crée un transfert d'argent à un destinataire spécifié.
    func createTransfer(recipient: String, amount: Float) async throws {
        print("createTransfer called with recipient: \(recipient) and amount: \(amount)")
        
        var request = URLRequest(url: RemoteAccountService.url.appendingPathComponent("account/transfer"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let transferInformation = TransferInformation(recipient: recipient, amount: amount)
        do {
            request.httpBody = try JSONEncoder().encode(transferInformation)
            print("HTTP body set with encoded transfer information")
            
            let (data, response) = try await networkManager.data(for: request, authenticatedRequest: true)
            print("Received response: \(response.statusCode)")
            print("Received data: \(String(data: data, encoding: .utf8) ?? "No data")")
            
            guard response.statusCode == 200 else {
                print("Non-200 status code received: \(response.statusCode)")
                if response.statusCode == 401 {
                    throw AuthServiceError.unauthorized
                } else if response.statusCode >= 500 {
                    throw AuthServiceError.serverError
                } else {
                    throw AuthServiceError.invalidResponse
                }
            }
        } catch {
            print("Caught error in createTransfer: \(error)")
            throw error
        }
    }
}
