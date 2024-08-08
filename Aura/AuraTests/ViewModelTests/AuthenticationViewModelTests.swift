//
//  AuthenticationViewModelTests.swift
//  AuraTests
//
//  Created by Margot Pasquali on 29/07/2024.
//

import XCTest
@testable import Aura

// ViewModel Tests
class AuthenticationViewModelTests: XCTestCase {

    var viewModel: AuthenticationViewModel?
    var mockAuthService: MockAuthService!
    var mockAccountService: MockAccountService!

    override func setUp() {
        super.setUp()
        
        mockAuthService = MockAuthService()
        mockAccountService = MockAccountService()
        
        viewModel = AuthenticationViewModel(authService: mockAuthService, accountService: mockAccountService) { result in
            XCTAssertTrue(result)
        }
    }

    override func tearDown() {
        viewModel = nil

        super.tearDown()
    }

    func testPerformAuthenticationSuccessful() async throws {
        viewModel?.username = "test@aura.app"
        viewModel?.password = "test123"

        do {
            try await viewModel?.performAuthentication()
        } catch {
            XCTFail("Authentication failed with error: \(error)")
        }

        XCTAssertTrue(viewModel?.isLoading == false)
    }

    func testPerformAuthenticationFailed() async throws {
        viewModel?.username = "test@aura.app"
        viewModel?.password = "test123"
        mockAuthService.authServiceError = .invalidCredentials

        do {
            try await viewModel?.performAuthentication()
            XCTFail("Expected authentication to fail")
        } catch AuthenticationViewModel.AuthenticationViewModelError.authenticationFailed {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        XCTAssertTrue(viewModel?.isLoading == false)
    }

    func testRetrieveAccountDetailsSuccessful() async throws {
        do {
            try await viewModel?.retrieveAccountDetails()
        } catch {
            XCTFail("Retrieving account details failed with error: \(error)")
        }

        XCTAssertTrue(viewModel?.isLoading == false)
    }

    func testRetrieveAccountDetailsFailed() async throws {
        mockAccountService.accountServiceError = .missingToken

        do {
            try await viewModel?.retrieveAccountDetails()
            XCTFail("Expected retrieval to fail")
        } catch AuthenticationViewModel.AuthenticationViewModelError.missingAccountDetails {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        XCTAssertTrue(viewModel?.isLoading == false)
    }

    func testLoginSuccessful() async throws {
        viewModel?.username = "test@aura.app"
        viewModel?.password = "test123"
        
        do {
            try await viewModel?.login()
        } catch {
            XCTFail("Login failed with error: \(error)")
        }
        
        XCTAssertTrue(viewModel?.isLoading == false)
    }

    func testLoginFailedAtAuthentication() async throws {
        viewModel?.username = "test@aura.app"
        viewModel?.password = "wrongpassword"
        mockAuthService.authServiceError = .invalidCredentials

        do {
            try await viewModel?.login()
            XCTFail("Expected login to fail at authentication")
        } catch AuthenticationViewModel.AuthenticationViewModelError.authenticationFailed {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        XCTAssertTrue(viewModel?.isLoading == false)
    }

    func testLoginFailedAtRetrieveAccountDetails() async throws {
        viewModel?.username = "test@aura.app"
        viewModel?.password = "test123"
        mockAccountService.accountServiceError = .missingToken
        
        do {
            try await viewModel?.login()
            XCTFail("Expected login to fail at retrieving account details")
        } catch AuthenticationViewModel.AuthenticationViewModelError.missingAccountDetails {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        XCTAssertTrue(viewModel?.isLoading == false)
    }
}
