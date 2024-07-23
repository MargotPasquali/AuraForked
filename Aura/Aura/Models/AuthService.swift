//
//  AuthService.swift
//  Aura
//
//  Created by Margot Pasquali on 11/07/2024.
//

import Foundation

struct AuthenticationRequest: Encodable {
    let username: String
    let password: String
}

struct TransferInformation: Encodable {
    let recipient: String
    let amount: Float
}

struct AuthenticationResponse: Decodable {
    let token: String
}

class AuthService {
    
    enum AuthServiceError: Error {
        case invalidCredentials
        case invalidResponse
        case unauthorized
        case missingToken
        case unknown
    }
    
    static var shared = AuthService(urlSession: URLSession.shared) // singleton
    
    private static let url = URL(string: "http://127.0.0.1:8080/")!
    private static var token: String?
    
    private var task: URLSessionDataTask?
    private var urlSession: URLSession
    
    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
    
    func authenticate(username: String, password: String) async throws {
        guard !username.isEmpty, !password.isEmpty else {
            throw AuthServiceError.invalidCredentials
        }
        print("getAuth called with username: \(username) and password: \(password)")
        
        var request = URLRequest(url: AuthService.url.appendingPathComponent("auth"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let emailAndPassword = AuthenticationRequest(username: username, password: password)
        do {
            request.httpBody = try JSONEncoder().encode(emailAndPassword)
            
            let (data, response) = try await urlSession.data(for: request)
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw AuthServiceError.invalidResponse
            }
            
            let authenticationResponse = try JSONDecoder().decode(AuthenticationResponse.self, from: data)
            
            AuthService.token = authenticationResponse.token
        } catch{
            throw AuthServiceError.unknown
        }
    }
    
    
    func logAccount() async throws -> AccountDetail {
        print("logAccount called")
        guard let token = AuthService.token else {
            throw AuthServiceError.missingToken
        }
        
        var request = URLRequest(url: AuthService.url.appendingPathComponent("account"))
        request.setValue(token, forHTTPHeaderField: "token")
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw AuthServiceError.invalidResponse
            }
            
            return try JSONDecoder().decode(AccountDetail.self, from: data)
        } catch {
            throw AuthServiceError.unknown
        }
    }
    
    func createTransfer(recipient: String, amount: Float) async throws {
        print("createTransfer called with recipient: \(recipient) and amount: \(amount)")
        guard let token = AuthService.token else {
            throw AuthServiceError.missingToken
        }
        
        var request = URLRequest(url: AuthService.url.appendingPathComponent("account/transfer"))
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "token")
        
        let transferInformation = TransferInformation(recipient: recipient, amount: amount)
        
        do {
            request.httpBody = try JSONEncoder().encode(transferInformation)
            
            let (data, response) = try await urlSession.data(for: request)
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw AuthServiceError.invalidResponse
            }
        } catch {
            throw AuthServiceError.unknown
        }
        
    }
}
