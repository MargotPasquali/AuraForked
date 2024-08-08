//
//  MoneyTransferViewModelTests.swift
//  AuraTests
//
//  Created by Margot Pasquali on 05/08/2024.
//

import XCTest
@testable import Aura

final class MoneyTransferViewModelTests: XCTestCase {
    var viewModel: MoneyTransferViewModel!
    var mockAccountService: MockAccountService!
    var mockAccountDetailViewModel: AccountDetailViewModel!

    override func setUp() {
        super.setUp()
        mockAccountService = MockAccountService()
        mockAccountDetailViewModel = AccountDetailViewModel(accountService: mockAccountService)
        viewModel = MoneyTransferViewModel(accountDetailViewModel: mockAccountDetailViewModel, accountService: mockAccountService)
    }

    override func tearDown() {
        viewModel = nil
        mockAccountService = nil
        mockAccountDetailViewModel = nil
        MockAccountService.accountServiceError = nil
        MockAccountService.accountDetails = AccountDetail(currentBalance: 1234.56, transactions: [])
        super.tearDown()
    }

    func testSendMoneyEmptyFields() async {
        // Given
        viewModel.recipient = ""
        viewModel.amount = ""
        print("Testing sendMoney with empty fields")
        // When
        do {
            try await viewModel.sendMoney()
            XCTFail("Expected send money to throw an error, but it did not.")
        } catch MoneyTransferViewModel.MoneyTransferError.emptyField {
            XCTAssertEqual(viewModel.transferMessage, "Fields cannot be empty")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testSendMoneyFailed() async {
        // Given
        viewModel.recipient = "recipient@example.com"
        viewModel.amount = "100"
        MockAccountService.accountServiceError = .networkError
        print("Testing sendMoney with network error")

        // When
        do {
            try await viewModel.sendMoney()
            XCTFail("Expected send money to fail due to network error, but it did not.")
        } catch MockServiceError.networkError {
            XCTAssertEqual(viewModel.transferMessage, "Transfer failed: A network error occurred.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }


    func testSendMoneyInvalidRecipient() async {
        // Given
        viewModel.recipient = "invalidrecipient"
        viewModel.amount = "100"
        print("Testing sendMoney with invalid recipient")
        // When
        do {
            try await viewModel.sendMoney()
            XCTFail("Expected send money to throw an error, but it did not.")
        } catch MoneyTransferViewModel.MoneyTransferError.invalidRecipientOrAmount {
            XCTAssertEqual(viewModel.transferMessage, "Invalid recipient or amount")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testSendMoneySuccessful() async {
        // Given
        viewModel.recipient = "recipient@example.com"
        viewModel.amount = "100"
        print("Testing sendMoney successfully")
        // When
        do {
            try await viewModel.sendMoney()
            XCTAssertEqual(viewModel.transferMessage, "Successfully transferred 100 to recipient@example.com")
        } catch {
            XCTFail("Expected send money to succeed, but it failed with error: \(error)")
        }
    }
}
