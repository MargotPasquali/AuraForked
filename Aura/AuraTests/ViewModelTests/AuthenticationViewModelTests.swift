//
//  AuthenticationViewModelTests.swift
//  AuraTests
//
//  Created by Margot Pasquali on 29/07/2024.
//

import XCTest
@testable import Aura

// MARK: - AuthenticationViewModelTests

/// Tests unitaires pour `AuthenticationViewModel`.
///
/// Cette classe de tests vérifie les différentes fonctionnalités du `AuthenticationViewModel`, telles que l'authentification et la récupération des détails du compte.
final class AuthenticationViewModelTests: XCTestCase {
    
    // MARK: - Properties
    
    var viewModel: AuthenticationViewModel!
    var mockAuthService: MockAuthService!
    var mockAccountService: MockAccountService!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        let mockNetworkManager = MockNetworkManager()
        mockAuthService = MockAuthService(networkManager: mockNetworkManager)
        mockAccountService = MockAccountService()
        viewModel = AuthenticationViewModel(authService: mockAuthService, accountService: mockAccountService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockAuthService = nil
        mockAccountService = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    /// Teste une authentification réussie.
    func testPerformAuthenticationSuccessful() async throws {
        // Given
        viewModel.username = "test@example.com"
        viewModel.password = "password"
        mockAuthService.authResponse = AuthenticationResponse(token: "valid-token")
        
        // When
        do {
            try await viewModel.performAuthentication()
            // Then
            XCTAssertNil(viewModel.errorMessage)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    /// Teste une authentification échouée.
    func testPerformAuthenticationFailed() async throws {
        // Given
        viewModel.username = "test@example.com"
        viewModel.password = "password"
        mockAuthService.error = AuthServiceError.unauthorized
        
        // When
        do {
            try await viewModel.performAuthentication()
            XCTFail("Expected authentication to fail")
        } catch AuthenticationViewModel.AuthenticationViewModelError.authenticationFailed {
            // Then
            XCTAssertNil(viewModel.errorMessage)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    /// Teste la récupération réussie des détails du compte.
    func testRetrieveAccountDetailsSuccessful() async throws {
        // Given
        viewModel.username = "test@example.com"
        viewModel.password = "password"
        
        // When
        do {
            try await viewModel.retrieveAccountDetails()
            // Then
            XCTAssertNil(viewModel.errorMessage)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    /// Teste l'échec de la récupération des détails du compte.
    func testRetrieveAccountDetailsFailed() async throws {
        // Given
        mockAccountService.accountServiceError = AccountServiceError.missingToken
        
        // When
        do {
            try await viewModel.retrieveAccountDetails()
            XCTFail("Expected account details retrieval to fail")
        } catch AuthenticationViewModel.AuthenticationViewModelError.missingAccountDetails {
            // Then
            XCTAssertNil(viewModel.errorMessage)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    /// Teste un processus de connexion réussi.
    func testLoginSuccessful() async throws {
        // Given
        viewModel.username = "test@example.com"
        viewModel.password = "password"
        mockAuthService.authResponse = AuthenticationResponse(token: "valid-token")
        
        // When
        do {
            try await viewModel.login()
            // Then
            XCTAssertFalse(viewModel.isLoading)
            XCTAssertNil(viewModel.errorMessage)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    /// Teste un échec de connexion dû à une erreur d'authentification.
    func testLoginFailedDueToAuthenticationError() async throws {
        // Given
        viewModel.username = "test@example.com"
        viewModel.password = "password"
        mockAuthService.error = AuthServiceError.unauthorized
        
        // When
        do {
            try await viewModel.login()
            XCTFail("Expected login to fail due to authentication error")
        } catch {
            // Then
            XCTAssertFalse(viewModel.isLoading)
            XCTAssertTrue(error is AuthenticationViewModel.AuthenticationViewModelError)
            
            if let viewModelError = error as? AuthenticationViewModel.AuthenticationViewModelError {
                XCTAssertEqual(viewModelError, .authenticationFailed)
            } else {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    /// Teste un échec de connexion dû à une erreur lors de la récupération des détails du compte.
    func testLoginFailedDueToAccountDetailsError() async throws {
        // Given
        viewModel.username = "test@example.com"
        viewModel.password = "password"
        mockAuthService.authResponse = AuthenticationResponse(token: "valid-token")
        mockAccountService.accountServiceError = AccountServiceError.missingToken
        
        // When
        do {
            try await viewModel.login()
            XCTFail("Expected login to fail due to missing account details")
        } catch {
            // Then
            XCTAssertFalse(viewModel.isLoading)
            XCTAssertTrue(error is AuthenticationViewModel.AuthenticationViewModelError)
            
            if let viewModelError = error as? AuthenticationViewModel.AuthenticationViewModelError {
                XCTAssertEqual(viewModelError, .missingAccountDetails)
            } else {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
}
