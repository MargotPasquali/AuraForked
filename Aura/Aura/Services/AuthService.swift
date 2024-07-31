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

struct AuthenticationResponse: Codable {
    let token: String
}

protocol AuthService {

    static var token: String? { get }

    func authenticate(username: String, password: String) async throws

}

final class RemoteAuthService: AuthService {

    enum AuthServiceError: Error {
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
    
    func authenticate(username: String, password: String) async throws {
        guard !username.isEmpty, !password.isEmpty else {
            throw AuthServiceError.invalidCredentials
        }
        print("getAuth called with username: \(username) and password: \(password)")
        
        var request = URLRequest(url: RemoteAuthService.url.appendingPathComponent("auth"))
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
            
            RemoteAuthService.token = authenticationResponse.token
        } catch {
            throw AuthServiceError.unknown
        }
    }
    
}
