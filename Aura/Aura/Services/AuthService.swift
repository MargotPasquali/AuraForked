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
    var networkManager: NetworkManager { get }

    init(networkManager: NetworkManager)

    func authenticate(username: String, password: String) async throws
}

enum AuthServiceError: Error {
    case invalidCredentials
    case invalidResponse
    case unauthorized
    case missingToken
    case unknown
}

final class RemoteAuthService: AuthService {

    private static let url = URL(string: "http://127.0.0.1:8080/")!

    let networkManager: NetworkManager

    private var task: URLSessionDataTask?

    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
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

            let (data, _) = try await networkManager.data(for: request, authenticatedRequest: false)

            do {
                let authenticationResponse = try JSONDecoder().decode(AuthenticationResponse.self, from: data)
                print("Decoded authentication response: \(authenticationResponse)")
                
                if authenticationResponse.token == "INVALID_TOKEN" {
                    print("Unauthorized token: \(authenticationResponse.token)")
                    throw AuthServiceError.unauthorized
                }
                
                networkManager.set(token: authenticationResponse.token)
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
