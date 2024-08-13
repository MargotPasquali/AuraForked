//
//  AuthenticationViewModelTests.swift
//  AuraTests
//
//  Created by Margot Pasquali on 29/07/2024.
//

import XCTest
@testable import Aura

final class AuthenticationViewModelTests: XCTestCase {

    var viewModel: AuthenticationViewModel!
    var mockAuthService: MockAuthService!
    var mockAccountService: MockAccountService!

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
