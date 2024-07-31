//
//  AuthenticationViewModelTests.swift
//  AuraTests
//
//  Created by Margot Pasquali on 29/07/2024.
//

import XCTest
@testable import Aura

// Mock Services
struct MockAuthService: AuthService {
    static var token: String?
    static var authServiceError: RemoteAuthService.AuthServiceError?

    func authenticate(username: String, password: String) async throws {
        if let authServiceError = Self.authServiceError {
            throw authServiceError
        } else {
            Self.token = "FB24D136-C228-491D-AB30-FDFD97009D19"
        }
    }
}

struct MockAccountService: AccountService {
    static var accountServiceError: RemoteAccountService.AccountServiceError?
    static var accountDetails: AccountDetail = AccountDetail(currentBalance: 1234.56, transactions: [])

    func logAccount() async throws -> AccountDetail {
        if let accountServiceError = Self.accountServiceError {
            throw accountServiceError
        } else {
            return Self.accountDetails
        }
    }

    func createTransfer(recipient: String, amount: Float) async throws {
        // Mock implementation
    }
}

// ViewModel Tests
class AuthenticationViewModelTests: XCTestCase {

    var viewModel: AuthenticationViewModel?

    override func setUp() {
        super.setUp()
        
        let mockAuthService = MockAuthService()
        let mockAccountService = MockAccountService()
        
        viewModel = AuthenticationViewModel(authService: mockAuthService, accountService: mockAccountService) { result in
            XCTAssertTrue(result)
        }
    }

    override func tearDown() {
        viewModel = nil
        MockAuthService.token = nil
        MockAuthService.authServiceError = nil
        MockAccountService.accountServiceError = nil
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
        
        XCTAssertEqual(MockAuthService.token, "FB24D136-C228-491D-AB30-FDFD97009D19")
    }

    func testPerformAuthenticationFailed() async throws {
        viewModel?.username = "test@aura.app"
        viewModel?.password = "test123"
        MockAuthService.authServiceError = .invalidCredentials
        
        do {
            try await viewModel?.performAuthentication()
            XCTFail("Expected authentication to fail")
        } catch AuthenticationViewModel.AuthenticationViewModelError.authenticationFailed {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testRetrieveAccountDetailsSuccessful() async throws {
        MockAuthService.token = "FB24D136-C228-491D-AB30-FDFD97009D19"

        do {
            try await viewModel?.retrieveAccountDetails()
        } catch {
            XCTFail("Retrieving account details failed with error: \(error)")
        }
    }

    func testRetrieveAccountDetailsFailed() async throws {
        MockAuthService.token = "FB24D136-C228-491D-AB30-FDFD97009D19"
        MockAccountService.accountServiceError = .missingToken
        
        do {
            try await viewModel?.retrieveAccountDetails()
            XCTFail("Expected retrieval to fail")
        } catch AuthenticationViewModel.AuthenticationViewModelError.missingAccountDetails {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testLoginSuccessful() async throws {
        viewModel?.username = "test@aura.app"
        viewModel?.password = "test123"
        
        do {
            try await viewModel?.login()
        } catch {
            XCTFail("Login failed with error: \(error)")
        }
        
        XCTAssertEqual(MockAuthService.token, "FB24D136-C228-491D-AB30-FDFD97009D19")
    }

    func testLoginFailedAtAuthentication() async throws {
        viewModel?.username = "test@aura.app"
        viewModel?.password = "wrongpassword"
        MockAuthService.authServiceError = .invalidCredentials
        
        do {
            try await viewModel?.login()
            XCTFail("Expected login to fail at authentication")
        } catch AuthenticationViewModel.AuthenticationViewModelError.authenticationFailed {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testLoginFailedAtRetrieveAccountDetails() async throws {
        viewModel?.username = "test@aura.app"
        viewModel?.password = "test123"
        MockAccountService.accountServiceError = .missingToken
        
        do {
            try await viewModel?.login()
            XCTFail("Expected login to fail at retrieving account details")
        } catch AuthenticationViewModel.AuthenticationViewModelError.missingAccountDetails {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
