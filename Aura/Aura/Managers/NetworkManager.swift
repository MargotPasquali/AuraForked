//
//  NetworkManager.swift
//  Aura
//
//  Created by Margot Pasquali on 08/08/2024.
//

import Foundation

final class NetworkManager {

    // MARK: - Constants

    static let shared = NetworkManager()

    private var urlSession: URLSession

    // MARK: - Properties

    private(set) var token: String?

    // MARK: - Initialisation

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    // MARK: - Functions

    func set(token: String) {
        guard !token.isEmpty else {
            return
        }
        
        self.token = token
    }

    func set(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    func data(for request: URLRequest, authenticatedRequest: Bool = true) async throws -> (Data, HTTPURLResponse) {
        var customRequest = request

        if authenticatedRequest {
            guard let token else {
                throw AuthServiceError.missingToken
            }

            customRequest.setValue(token, forHTTPHeaderField: "token")
        }

        let (data, response) = try await urlSession.data(for: customRequest, delegate: nil)

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

        return (data, response)
    }
}
