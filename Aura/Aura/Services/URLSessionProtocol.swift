//
//  URLSessionProtocol.swift
//  Aura
//
//  Created by Margot Pasquali on 29/07/2024.
//

import Foundation

protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}
