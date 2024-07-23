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
        let urlSession = URLSessionFake(data: FakeResponseData.authCorrectData, response: FakeResponseData.responseOk, error: nil)
        let accountSession = URLSessionFake(data: FakeResponseData.logAccountCorrectData, response: FakeResponseData.responseOk, error: nil)
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

        let expectation = self.expectation(description: "Login should succeed")

        // Perform login
        viewModel.username = "test@aura.app"
        viewModel.password = "test123"

        Task {
            await viewModel.login()
            expectation.fulfill()
        }

        await waitForExpectations(timeout: 5, handler: { error in
            if error != nil {
                print("Timeout Error: \(String(describing: error))")
            }
        })

        XCTAssertTrue(viewModel.isAuthenticated, "User should be authenticated")
    }
}
