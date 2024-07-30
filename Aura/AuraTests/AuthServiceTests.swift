//
//  AuthServiceTests.swift
//  AuraTests
//
//  Created by Margot Pasquali on 29/07/2024.
//

import XCTest
@testable import Aura

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

    }
}

class AuthServiceTests: XCTestCase {

    var authService: AuthService!
    private var urlSession: URLSession!

    override func setUp() {
        super.setUp()

        let urlSessionConfiguration = URLSession.shared.configuration
        urlSessionConfiguration.protocolClasses = [MockProtocol.self]

        authService = RemoteAuthService(urlSession: URLSession(configuration: urlSessionConfiguration))
    }

    override func tearDown() {
        MockProtocol.requestHandler = nil

        authService = nil

        super.tearDown()
    }

    func testAuthenticateSuccessful() async throws {
        // Given
        MockProtocol.requestHandler = { request in
            let data = try! JSONEncoder().encode(AuthenticationResponse(token: "FB24D136-C228-491D-AB30-FDFD97009D19"))

            return (FakeResponseData.responseOk, data)
        }

        // When
        try await authService.authenticate(username: "test@aura.app", password: "test123")

        // Then
        XCTAssertEqual(RemoteAuthService.token, "FB24D136-C228-491D-AB30-FDFD97009D19")
    }
    
    func testLogAccountSuccessful() async throws {
        // Given
        MockProtocol.requestHandler = { request in
            (FakeResponseData.responseOk, FakeResponseData.logAccountCorrectData)
        }

        RemoteAuthService.token = "FB24D136-C228-491D-AB30-FDFD97009D19"

        // When
        let accountDetail = try await authService.logAccount()

        // Then
        XCTAssertEqual(accountDetail.currentBalance, 1234.56)
        XCTAssertEqual(accountDetail.transactions.count, 2)
    }
}
