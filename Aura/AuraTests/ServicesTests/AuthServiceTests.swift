//
//  AuthServiceTests.swift
//  AuraTests
//
//  Created by Margot Pasquali on 29/07/2024.
//

import XCTest
@testable import Aura

class AuthServiceTests: XCTestCase {

    var authService: RemoteAuthService! // Use specific type
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
        XCTAssertEqual(authService.token, "FB24D136-C228-491D-AB30-FDFD97009D19")
    }

    func testAuthenticateWithInvalidToken() async throws {
        // Given
        MockProtocol.requestHandler = { request in
            print("Handling request with invalid token: \(request)")
            return (FakeResponseData.responseOk, FakeResponseData.authIncorrectData)
        }

        // When
        do {
            try await authService.authenticate(username: "test@aura.app", password: "test123")
            XCTFail("Expected authentication to fail due to invalid token")
        } catch RemoteAuthService.AuthServiceError.unauthorized {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testAuthenticateWithMissingCredentials() async throws {
        // Given
        MockProtocol.requestHandler = { request in
            print("Handling request with missing credentials: \(request)")
            return (FakeResponseData.responseOk, FakeResponseData.authCorrectData)
        }

        // When
        do {
            try await authService.authenticate(username: "", password: "")
            XCTFail("Expected authentication to fail due to missing credentials")
        } catch RemoteAuthService.AuthServiceError.invalidCredentials {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testAuthenticateWithNon200Response() async throws {
        // Given
        MockProtocol.requestHandler = { request in
            print("Handling request with non-200 response: \(request)")
            let response = HTTPURLResponse(url: request.url!, statusCode: 400, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        // When
        do {
            try await authService.authenticate(username: "test@aura.app", password: "test123")
            XCTFail("Expected authentication to fail due to non-200 HTTP response")
        } catch RemoteAuthService.AuthServiceError.invalidResponse {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testAuthenticateWithUnauthorizedResponse() async throws {
        // Given
        MockProtocol.requestHandler = { request in
            print("Handling request with unauthorized response: \(request)")
            let response = HTTPURLResponse(url: request.url!, statusCode: 401, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        // When
        do {
            try await authService.authenticate(username: "test@aura.app", password: "test123")
            XCTFail("Expected authentication to fail due to unauthorized response")
        } catch RemoteAuthService.AuthServiceError.unauthorized {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testAuthenticateWithServerError() async throws {
        // Given
        MockProtocol.requestHandler = { request in
            print("Handling request with server error: \(request)")
            return (FakeResponseData.responseKo, FakeResponseData.incorrectData)
        }

        // When
        do {
            try await authService.authenticate(username: "test@aura.app", password: "test123")
            XCTFail("Expected authentication to fail due to server error")
        } catch RemoteAuthService.AuthServiceError.unknown {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testAuthenticateWithInvalidJSONResponse() async throws {
        // Given
        MockProtocol.requestHandler = { request in
            print("Handling request with invalid JSON response: \(request)")
            return (FakeResponseData.responseOk, FakeResponseData.incorrectData)
        }

        // When
        do {
            try await authService.authenticate(username: "test@aura.app", password: "test123")
            XCTFail("Expected authentication to fail due to invalid JSON response")
        } catch RemoteAuthService.AuthServiceError.invalidResponse {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testAuthenticateWithEmptyUsername() async throws {
        // Given
        MockProtocol.requestHandler = { request in
            print("Handling request with empty username: \(request)")
            return (FakeResponseData.responseOk, FakeResponseData.authCorrectData)
        }

        // When
        do {
            try await authService.authenticate(username: "", password: "test123")
            XCTFail("Expected authentication to fail due to empty username")
        } catch RemoteAuthService.AuthServiceError.invalidCredentials {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testAuthenticateWithEmptyPassword() async throws {
        // Given
        MockProtocol.requestHandler = { request in
            print("Handling request with empty password: \(request)")
            return (FakeResponseData.responseOk, FakeResponseData.authCorrectData)
        }

        // When
        do {
            try await authService.authenticate(username: "test@aura.app", password: "")
            XCTFail("Expected authentication to fail due to empty password")
        } catch RemoteAuthService.AuthServiceError.invalidCredentials {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testTokenPersistence() async throws {
        // Given
        MockProtocol.requestHandler = { request in
            print("Handling request: \(request)")
            return (FakeResponseData.responseOk, FakeResponseData.authCorrectData)
        }

        // When
        try await authService.authenticate(username: "test@aura.app", password: "test123")

        // Then
        XCTAssertEqual(authService.token, "FB24D136-C228-491D-AB30-FDFD97009D19")
    }
}
