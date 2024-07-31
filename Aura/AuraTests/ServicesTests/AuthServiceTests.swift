//
//  AuthServiceTests.swift
//  AuraTests
//
//  Created by Margot Pasquali on 29/07/2024.
//

import XCTest
@testable import Aura

class AuthServiceTests: XCTestCase {

    var authService: AuthService!
    private var urlSession: URLSession!

    override func setUp() {
        super.setUp()

        let urlSessionConfiguration = URLSessionConfiguration.ephemeral
        urlSessionConfiguration.protocolClasses = [MockProtocol.self]
        urlSession = URLSession(configuration: urlSessionConfiguration)

        authService = RemoteAuthService(urlSession: urlSession)
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
}
