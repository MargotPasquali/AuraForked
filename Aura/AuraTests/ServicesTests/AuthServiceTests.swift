//
//  AuthServiceTests.swift
//  AuraTests
//
//  Created by Margot Pasquali on 29/07/2024.
//

import XCTest
@testable import Aura

// MARK: - AuthServiceTests

/// Tests unitaires pour `AuthService`.
///
/// Cette classe de tests vérifie les différentes fonctionnalités du `AuthService`,
/// telles que l'authentification réussie, la gestion des erreurs de réseau, et la gestion des réponses incorrectes.
class AuthServiceTests: XCTestCase {
    
    // MARK: - Properties
    
    var authService: AuthService!
    var mockNetworkManager: MockNetworkManager!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        authService = RemoteAuthService(networkManager: mockNetworkManager)
    }
    
    override func tearDown() {
        mockNetworkManager = nil
        authService = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    /// Teste une authentification réussie.
    func testAuthenticateSuccessful() async throws {
        // Given
        mockNetworkManager.response = FakeResponseData.responseOk
        mockNetworkManager.responseData = FakeResponseData.authCorrectData
        mockNetworkManager.error = nil
        
        // When
        do {
            try await authService.authenticate(username: "testuser", password: "password")
            
            // Then
            XCTAssertNotNil(mockNetworkManager.token, "Token should be set after successful authentication")
            XCTAssertEqual(mockNetworkManager.token, "FB24D136-C228-491D-AB30-FDFD97009D19")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    /// Teste l'authentification avec des identifiants invalides.
    func testAuthenticateWithInvalidCredentials() async throws {
        // Given
        mockNetworkManager.response = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/auth")!, statusCode: 401, httpVersion: nil, headerFields: nil)!
        mockNetworkManager.responseData = Data("{\"token\": \"INVALID_TOKEN\"}".utf8)
        mockNetworkManager.error = nil
        
        // When
        do {
            try await authService.authenticate(username: "invaliduser", password: "invalidpassword")
            XCTFail("Expected authentication to fail due to invalid credentials")
        } catch AuthServiceError.unauthorized {
            // Then
            print("Caught expected AuthServiceError.unauthorized")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    /// Teste l'authentification avec des identifiants manquants.
    func testAuthenticateWithMissingCredentials() async throws {
        // Given
        let emptyUsername = ""
        let emptyPassword = ""
        
        // When
        do {
            try await authService.authenticate(username: emptyUsername, password: emptyPassword)
            XCTFail("Expected authentication to fail due to missing credentials")
        } catch AuthServiceError.invalidCredentials {
            // Then
            print("Caught expected AuthServiceError.invalidCredentials")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    /// Teste l'authentification avec une erreur de serveur.
    func testAuthenticateWithServerError() async throws {
        // Given
        mockNetworkManager.response = FakeResponseData.responseKo
        mockNetworkManager.responseData = Data() // Aucune donnée car c'est une erreur de serveur
        mockNetworkManager.error = nil
        
        // When
        do {
            try await authService.authenticate(username: "testuser", password: "password")
            XCTFail("Expected authentication to fail due to server error")
        } catch AuthServiceError.serverError {
            // Then
            print("Caught expected AuthServiceError.serverError")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    /// Teste l'authentification avec une erreur de réseau.
    func testAuthenticateWithNetworkError() async throws {
        // Given
        let networkError = URLError(.notConnectedToInternet)
        mockNetworkManager.error = networkError
        print("Configured mock network error: \(networkError)")
        
        // When
        do {
            try await authService.authenticate(username: "testuser", password: "password")
            XCTFail("Expected authentication to fail due to network error")
        } catch AuthServiceError.networkError(let error) {
            // Then
            XCTAssertEqual((error as? URLError)?.code, networkError.code)
            print("Caught expected AuthServiceError.networkError: \(error)")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    /// Teste l'authentification avec des données incorrectes.
    func testAuthenticateWithInvalidData() async throws {
        // Given
        mockNetworkManager.response = FakeResponseData.responseOk
        mockNetworkManager.responseData = FakeResponseData.incorrectData
        mockNetworkManager.error = nil
        
        // When
        do {
            try await authService.authenticate(username: "testuser", password: "password")
            XCTFail("Expected authentication to fail due to invalid data")
        } catch AuthServiceError.decodingError(let error) {
            // Then
            print("Caught expected AuthServiceError.decodingError: \(error)")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
