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
        await viewModel?.fetchAccountDetails()
        
        // Donnons le temps aux mises à jour de se faire sur le thread principal
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconde
        
        guard let totalAmount = viewModel?.totalAmount else {
            XCTFail("totalAmount is nil")
            return
        }
        
        XCTAssertEqual(totalAmount, 1234.56, accuracy: 0.01)
        XCTAssertEqual(viewModel?.recentTransactions.count, 0)
    }

    func testFetchAccountDetailsFailed() async throws {
        MockAccountService.accountServiceError = .missingToken
        
        await viewModel?.fetchAccountDetails()
        
        // Donnons le temps aux mises à jour de se faire sur le thread principal
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconde
        
        guard let totalAmount = viewModel?.totalAmount else {
            XCTFail("totalAmount is nil")
            return
        }
        
        XCTAssertEqual(totalAmount, 0)
        XCTAssertEqual(viewModel?.recentTransactions.count, 0)
    }
}
