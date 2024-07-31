//
//  MockProtocol.swift
//  AuraTests
//
//  Created by Margot Pasquali on 31/07/2024.
//

import Foundation

final class MockProtocol: URLProtocol {

    static var requestHandler: ((URLRequest) -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let requestHandler = Self.requestHandler else {
            return
        }

        let (response, data) = requestHandler(request)

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
        // Pas besoin de faire quoi que ce soit ici
    }
}
