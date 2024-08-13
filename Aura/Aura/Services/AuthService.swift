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
    var networkManager: NetworkManagerProtocol { get }
    init(networkManager: NetworkManagerProtocol)
    func authenticate(username: String, password: String) async throws
}

enum AuthServiceError: Error {
    case invalidCredentials
    case invalidResponse
    case unauthorized
    case missingToken
    case serverError
    case networkError(Error)
    case decodingError(DecodingError)
    case unknown
}

final class RemoteAuthService: AuthService {
    private static let url = URL(string: "http://127.0.0.1:8080/")!
    let networkManager: NetworkManagerProtocol

    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }

    func authenticate(username: String, password: String) async throws {
        guard !username.isEmpty, !password.isEmpty else {
            throw AuthServiceError.invalidCredentials
        }
        print("Username and password validation passed.")

        var request = URLRequest(url: RemoteAuthService.url.appendingPathComponent("auth"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let credentials = AuthenticationRequest(username: username, password: password)
        request.httpBody = try JSONEncoder().encode(credentials)
        print("Request prepared with encoded credentials.")

        do {
            let (data, response) = try await networkManager.data(for: request, authenticatedRequest: false)
            print("Received data from network.")

            guard response.statusCode == 200 else {
                print("Received error response: \(response.statusCode)")
                if response.statusCode == 401 {
                    throw AuthServiceError.unauthorized
                } else if response.statusCode >= 500 {
                    throw AuthServiceError.serverError
                } else {
                    throw AuthServiceError.invalidResponse
                }
            }

            let authResponse = try JSONDecoder().decode(AuthenticationResponse.self, from: data)
            print("Decoded authentication response: \(authResponse)")

            if authResponse.token == "INVALID_TOKEN" {
                print("Unauthorized token received.")
                throw AuthServiceError.unauthorized
            }
            networkManager.set(token: authResponse.token)
        } catch let error as AuthServiceError {
            throw error  // Si c'est déjà un AuthServiceError, le relancer tel quel
        } catch let urlError as URLError {
            print("Caught URLError: \(urlError)")
            throw AuthServiceError.networkError(urlError)
        } catch let decodingError as DecodingError {
            print("Decoding error: \(decodingError)")
            throw AuthServiceError.decodingError(decodingError)
        } catch {
            print("Caught unknown error: \(error)")
            throw AuthServiceError.unknown
        }
    }

}
