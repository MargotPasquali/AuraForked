//
//  AuthenticationViewModelTests.swift
//  AuraTests
//
//  Created by Margot Pasquali on 17/07/2024.
//

import XCTest
@testable import Aura

class AuthenticationViewModelTests: XCTestCase {

    var viewModel: AuthenticationViewModel?
    
    override func setUp() {
        super.setUp()
        let authData = FakeResponseData.authCorrectData
        let accountData = FakeResponseData.logAccountCorrectData
        let responseOk = FakeResponseData.responseOk
        
        let urlSession = URLSessionFake(data: authData, response: responseOk, error: nil)
        let authService = AuthService(urlSession: urlSession)
        viewModel = AuthenticationViewModel(authService: authService) {}
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testValidateEmail() {
        XCTAssertTrue(AuthenticationViewModel.validateEmail("test@example.com"))
        XCTAssertFalse(AuthenticationViewModel.validateEmail("invalid-email"))
    }

    func testLoginSuccessful() async {
        guard let viewModel = viewModel else {
            XCTFail("ViewModel should not be nil")
            return
        }

        // Set up expectation
        let expectation = self.expectation(description: "Login should succeed")
        
        // Set callback to fulfill expectation
        viewModel.username = "test@aura.app"
        viewModel.password = "test123"
        
        Task {
            try await viewModel.login()
            expectation.fulfill()
        }
        
        await waitForExpectations(timeout: 5)
        
    }
}
