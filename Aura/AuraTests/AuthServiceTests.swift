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
    
    override func setUp() {
        super.setUp()
        let urlSession = URLSessionFake(data: FakeResponseData.authCorrectData, response: FakeResponseData.responseOk, error: nil)
        authService = AuthService(urlSession: urlSession as! URLSessionProtocol)
    }

    override func tearDown() {
        authService = nil
        super.tearDown()
    }

    func testAuthenticateSuccessful() async throws {
        try await authService.authenticate(username: "test@aura.app", password: "test123")
        XCTAssertEqual(authService.getToken(), "FB24D136-C228-491D-AB30-FDFD97009D19")
    }
    
    func testLogAccountSuccessful() async throws {
        // Setting up for logAccount
        authService.setToken("FB24D136-C228-491D-AB30-FDFD97009D19")
        let urlSession = URLSessionFake(data: FakeResponseData.logAccountCorrectData, response: FakeResponseData.responseOk, error: nil)
        authService = AuthService(urlSession: urlSession as! URLSessionProtocol)
        
        let accountDetail = try await authService.logAccount()
        XCTAssertEqual(accountDetail.currentBalance, 1234.56)
        XCTAssertEqual(accountDetail.transactions.count, 2)
    }
}
