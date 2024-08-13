//
//  NetworkManager.swift
//  Aura
//
//  Created by Margot Pasquali on 08/08/2024.
//

import Foundation

protocol NetworkManagerProtocol {
    var token: String? { get set }
    func data(for request: URLRequest, authenticatedRequest: Bool) async throws -> (Data, HTTPURLResponse)
    func set(token: String)
}

final class NetworkManager: NetworkManagerProtocol {
    static let shared = NetworkManager()

    private var urlSession: URLSession

    var token: String?  // La propriété doit correspondre au protocole

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func set(token: String) {
        guard !token.isEmpty else { return }
        self.token = token
    }

    func data(for request: URLRequest, authenticatedRequest: Bool = true) async throws -> (Data, HTTPURLResponse) {
        var customRequest = request

        if authenticatedRequest {
            guard let token = token else {
                throw AuthServiceError.missingToken
            }
            customRequest.setValue(token, forHTTPHeaderField: "token")
        }

        do {
            let (data, response) = try await urlSession.data(for: customRequest, delegate: nil)

            guard let response = response as? HTTPURLResponse else {
                throw AuthServiceError.invalidResponse
            }

            switch response.statusCode {
            case 200:
                return (data, response)
            case 401:
                throw AuthServiceError.unauthorized
            case 500...599:
                throw AuthServiceError.serverError
            default:
                throw AuthServiceError.invalidResponse
            }
        } catch let error as URLError {
            print("Caught URLError: \(error)")
            throw AuthServiceError.networkError(error)
        } catch {
            print("Caught generic error: \(error)")
            throw AuthServiceError.networkError(error)
        }
    }
}

