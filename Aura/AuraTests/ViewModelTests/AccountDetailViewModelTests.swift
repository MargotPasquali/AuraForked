//
//  AccountDetailViewModelTests.swift
//  AuraTests
//
//  Created by Margot Pasquali on 05/08/2024.
//

import XCTest
@testable import Aura

class AccountDetailViewModelTests: XCTestCase {

    var viewModel: AccountDetailViewModel?

    override func setUp() {
        super.setUp()
        
        let mockAccountService = MockAccountService()
        
        viewModel = AccountDetailViewModel(accountService: mockAccountService)
    }

    override func tearDown() {
        viewModel = nil
        MockAccountService.accountServiceError = nil
        super.tearDown()
    }

    func testFetchAccountDetailsSuccessful() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Fetch account details successfully")
        
        await viewModel?.fetchAccountDetails()
        
        // When
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)

        guard let totalAmount = viewModel?.totalAmount else {
            XCTFail("totalAmount is nil")
            return
        }
        // Then
        XCTAssertEqual(totalAmount, 1234.56, accuracy: 0.01)
        XCTAssertEqual(viewModel?.recentTransactions.count, 0)
    }

    func testFetchAccountDetailsFailed() async throws {
        // Given
        let expectation = XCTestExpectation(description: "Fetch account details failed")
        
        MockAccountService.accountServiceError = .missingToken
        
        await viewModel?.fetchAccountDetails()
        
        // When
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        guard let totalAmount = viewModel?.totalAmount else {
            XCTFail("totalAmount is nil")
            return
        }
        // Then
        XCTAssertEqual(totalAmount, 0.0)
        XCTAssertEqual(viewModel?.recentTransactions.count, 0)
    }
}
