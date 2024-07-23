//
//  URLSessionFake.swift
//  AuraTests
//
//  Created by Margot Pasquali on 15/07/2024.
//

import Foundation

class URLSessionFake: URLSession {
    
    var data: Data?
    var response: URLResponse?
    var error: Error?

    init(data: Data?, response: URLResponse?, error: Error?) {
        self.data = data
        self.response = response
        self.error = error
    }

    func data(for request: URLRequest) async throws {
        if let error = error {
            throw error
        }

        guard let data = data, let response = response else {
            throw URLError(.badServerResponse)
        }
    }
}
