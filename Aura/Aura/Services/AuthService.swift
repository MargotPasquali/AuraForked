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
    var token: String? { get set }
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
    var token: String?

    private var task: URLSessionDataTask?
    private var urlSession: URLSessionProtocol
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func authenticate(username: String, password: String) async throws {
        guard !username.isEmpty, !password.isEmpty else {
            throw AuthServiceError.invalidCredentials
        }
        print("authenticate called with username: \(username) and password: \(password)")
        
        var request = URLRequest(url: RemoteAuthService.url.appendingPathComponent("auth"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let emailAndPassword = AuthenticationRequest(username: username, password: password)
        do {
            request.httpBody = try JSONEncoder().encode(emailAndPassword)
            print("HTTP body set with encoded credentials")

            let (data, response) = try await urlSession.data(for: request)
            print("Received data: \(String(data: data, encoding: .utf8) ?? "nil")")
            print("Received response: \(response)")

            guard let response = response as? HTTPURLResponse else {
                print("Invalid response: not an HTTPURLResponse")
                throw AuthServiceError.invalidResponse
            }
            
            guard response.statusCode == 200 else {
                print("Invalid response status code: \(response.statusCode)")
                if response.statusCode == 401 {
                    throw AuthServiceError.unauthorized
                } else if response.statusCode >= 500 {
                    throw AuthServiceError.unknown
                } else {
                    throw AuthServiceError.invalidResponse
                }
            }
            
            do {
                let authenticationResponse = try JSONDecoder().decode(AuthenticationResponse.self, from: data)
                print("Decoded authentication response: \(authenticationResponse)")
                
                if authenticationResponse.token == "INVALID_TOKEN" {
                    print("Unauthorized token: \(authenticationResponse.token)")
                    throw AuthServiceError.unauthorized
                }
                
                self.token = authenticationResponse.token
            } catch let decodingError as DecodingError {
                print("Decoding error: \(decodingError)")
                throw AuthServiceError.invalidResponse
            }
        } catch let error as AuthServiceError {
            throw error
        } catch {
            print("Unknown error: \(error)")
            throw AuthServiceError.unknown
        }
    }
}
