//
//  MockNetworkManager.swift
//  AuraTests
//
//  Created by Margot Pasquali on 08/08/2024.
//

import Foundation
@testable import Aura

final class MockNetworkManager: NetworkManagerProtocol {
    var token: String?
    var responseData: Data?
    var response: HTTPURLResponse?
    var error: Error?

    func data(for request: URLRequest, authenticatedRequest: Bool) async throws -> (Data, HTTPURLResponse) {
        if let error = error {
            throw AuthServiceError.networkError(error)
        }

        guard let response = response, let responseData = responseData else {
            throw AuthServiceError.invalidResponse
        }

        return (responseData, response)
    }

    func set(token: String) {
        self.token = token
    }
}
