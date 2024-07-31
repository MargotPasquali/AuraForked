//
//  AccountService.swift
//  Aura
//
//  Created by Margot Pasquali on 30/07/2024.
//

import Foundation

protocol AccountService {
    func logAccount() async throws -> AccountDetail

    func createTransfer(recipient: String, amount: Float) async throws
}

final class RemoteAccountService: AccountService {
    
    enum AccountServiceError: Error {
        case invalidCredentials
        case invalidResponse
        case unauthorized
        case missingToken
        case unknown
    }

    private static let url = URL(string: "http://127.0.0.1:8080/")!

    static var token: String?

    private var task: URLSessionDataTask?
    private var urlSession: URLSessionProtocol
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    func logAccount() async throws -> AccountDetail {
        print("logAccount called")
        guard let token = RemoteAuthService.token else {
            throw AccountServiceError.missingToken
        }
        
        var request = URLRequest(url: RemoteAccountService.url.appendingPathComponent("account"))
        request.setValue(token, forHTTPHeaderField: "token")
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw AccountServiceError.invalidResponse
            }
            
            return try JSONDecoder().decode(AccountDetail.self, from: data)
        } catch {
            throw AccountServiceError.unknown
        }
    }
    
    func createTransfer(recipient: String, amount: Float) async throws {
        print("createTransfer called with recipient: \(recipient) and amount: \(amount)")
        guard let token = RemoteAuthService.token else {
            throw AccountServiceError.missingToken
        }
        
        var request = URLRequest(url: RemoteAccountService.url.appendingPathComponent("account/transfer"))
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "token")
        
        let transferInformation = TransferInformation(recipient: recipient, amount: amount)
        
        do {
            request.httpBody = try JSONEncoder().encode(transferInformation)
            
            let (data, response) = try await urlSession.data(for: request)
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw AccountServiceError.invalidResponse
            }
        } catch {
            throw AccountServiceError.unknown
        }
    }
}
