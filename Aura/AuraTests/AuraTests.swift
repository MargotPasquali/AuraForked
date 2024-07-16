//
//  AuraTests.swift
//  AuraTests
//
//  Created by Margot Pasquali on 15/07/2024.
//

import XCTest
@testable import Aura

final class AuraTests: XCTestCase {

    func testAuthService_WithCorrectData_ShouldReturnSuccess() {
        // Préparer les données de test
        let session = URLSessionFake(data: FakeResponseData.authCorrectData, response: FakeResponseData.responseOk, error: nil)
        let authService = AuthService(authSession: session)
        
        // Exécuter le test
        let expectation = self.expectation(description: "Auth success")
        authService.getAuth(username: "test@aura.app", password: "test123") { data, error in
            XCTAssertNotNil(data)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testEmailValidation() {
            let validEmails = ["test@example.com", "user.name+tag+sorting@example.com", "x@example.com", "example-indeed@strange-example.com"]
            let invalidEmails = ["plainaddress", "@missingusername.com", "username@.com", "username@com", "username@domain..com"]

            for email in validEmails {
                XCTAssertTrue(AuthenticationViewModel.validateEmail(email), "Valid email \(email) failed validation")
            }

            for email in invalidEmails {
                XCTAssertFalse(AuthenticationViewModel.validateEmail(email), "Invalid email \(email) passed validation")
            }

            print("All tests passed")
        }
}
