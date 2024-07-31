//
//  AuthenticationViewModelTests.swift
//  AuraTests
//
//  Created by Margot Pasquali on 29/07/2024.
//

import XCTest
@testable import Aura

struct MockAuthService: AuthService {
    
    static var token: String?
    
    static var authServiceError: RemoteAuthService.AuthServiceError?
    
    func authenticate(username: String, password: String) async throws {
        if let authServiceError = Self.authServiceError {
            throw authServiceError
        }
    }
}

struct MockAccountService: AccountService {
    
    
    static var accountServiceError: RemoteAccountService.AccountServiceError?
    
    func logAccount() async throws -> Aura.AccountDetail {
        if let authServiceError = Self.accountServiceError {
            throw authServiceError
        } else {
            try! JSONDecoder().decode(Aura.AccountDetail.self, from: FakeResponseData.logAccountCorrectData)
        }
    }
    
    func createTransfer(recipient: String, amount: Float) async throws {

    }
}

class AuthenticationViewModelTests: XCTestCase {

    var viewModel: AuthenticationViewModel?
    
    override func setUp() {
        super.setUp()
        
        viewModel = AuthenticationViewModel(authService: MockAuthService())
    }

    override func tearDown() {
        viewModel = nil

        super.tearDown()
    }

    func testValidateEmail() {
        XCTAssertTrue(AuthenticationViewModel.validateEmail("test@example.com"))
        XCTAssertFalse(AuthenticationViewModel.validateEmail("invalid-email"))
    }

    func testLoginSuccessful() async throws {
        let viewModel = AuthenticationViewModel(authService: MockAuthService()) { result in
            XCTAssertTrue(result)
        }

        viewModel.username = "test@aura.app"
        viewModel.password = "test123"
        
        try await viewModel.login()
    }

    func testLoginFailed() async throws {
        let viewModel = AuthenticationViewModel(authService: MockAuthService()) { result in
            XCTAssertTrue(result)
        }

        viewModel.username = "test@aura.app"
        viewModel.password = ""

        do {
            try await viewModel.login()
        } catch AuthenticationViewModel.AuthenticationViewModelError.authenticationFailed {
            // Good
            print("Good error")
        } catch {
            XCTFail("Wrong error")
        }
    }
}
