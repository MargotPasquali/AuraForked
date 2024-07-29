//
//  URLSessionFake.swift
//  AuraTests
//
//  Created by Margot Pasquali on 29/07/2024.
//

import Foundation
@testable import Aura

class URLSessionFake: URLSessionProtocol {
    var data: Data?
    var response: URLResponse?
    var error: Error?

    init(data: Data?, response: URLResponse?, error: Error?) {
        self.data = data
        self.response = response
        self.error = error
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        guard let data = data, let response = response else {
            throw URLError(.badServerResponse)
        }
        return (data, response)
    }
}
