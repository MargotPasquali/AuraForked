//
//  AuraTests.swift
//  AuraTests
//
//  Created by Margot Pasquali on 15/07/2024.
//

import XCTest
@testable import Aura

final class AuraTests: XCTestCase {


    
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
