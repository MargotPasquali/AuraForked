//
//  AccountDetailViewModelTests.swift
//  AuraTests
//
//  Created by Margot Pasquali on 05/08/2024.
//

import XCTest
@testable import Aura

final class AccountDetailViewModelTests: XCTestCase {
    
    var viewModel: AccountDetailViewModel!
    var mockAccountService: MockAccountService!

    override func setUp() {
        super.setUp()
        mockAccountService = MockAccountService()
        viewModel = AccountDetailViewModel(accountService: mockAccountService)
    }

    override func tearDown() {
        viewModel = nil
        mockAccountService = nil
        super.tearDown()
    }

    @MainActor
    func testFetchAccountDetailsSuccessful() async throws {
        // Given
        let expectedBalance = 1234.56
        let expectedTransactions = [
            Transaction(label: "Transaction 1", value: 100.0),
            Transaction(label: "Transaction 2", value: -50.0)
        ]
        mockAccountService.accountDetails = AccountDetail(currentBalance: expectedBalance, transactions: expectedTransactions)
        
        // Ajout de l'impression pour suivre les valeurs avant le fetch
        print("Before fetch: totalAmount = \(viewModel.totalAmount), recentTransactions = \(viewModel.recentTransactions.count)")
        
        // When
        await viewModel.fetchAccountDetails()
        
        // Ajout de l'impression pour suivre les valeurs après le fetch
        print("After fetch: totalAmount = \(viewModel.totalAmount), recentTransactions = \(viewModel.recentTransactions.count)")
        
        // Then
        XCTAssertEqual(viewModel.totalAmount, expectedBalance)
        XCTAssertEqual(viewModel.recentTransactions, expectedTransactions)
    }

    func testFetchAccountDetailsFailed() async throws {
        // Given
        mockAccountService.accountServiceError = AccountServiceError.missingToken

        // When
        await viewModel.fetchAccountDetails()

        // Then
        XCTAssertEqual(viewModel.totalAmount, 0)
        XCTAssertTrue(viewModel.recentTransactions.isEmpty)
    }
}
