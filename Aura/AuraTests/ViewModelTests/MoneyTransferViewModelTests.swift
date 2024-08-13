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
        super.tearDown()
    }

    func testSendMoneyWithEmptyFields() async throws {
        // Given
        viewModel.recipient = ""
        viewModel.amount = ""

        // Création d'une attente pour la mise à jour asynchrone
        let expectation = XCTestExpectation(description: "Waiting for transfer message to be updated")

        // When
        do {
            try await viewModel.sendMoney()
            XCTFail("Expected sendMoney to fail due to empty fields")
        } catch MoneyTransferViewModel.MoneyTransferError.emptyField {
            // Alors, ajoutez un petit délai pour que l'interface se mette à jour
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Then
                XCTAssertEqual(self.viewModel.transferMessage, "Fields cannot be empty")
                expectation.fulfill()
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        // Attend que l'attente soit remplie
        wait(for: [expectation], timeout: 1.0)
    }

    func testSendMoneyWithInvalidRecipient() async throws {
        // Given
        viewModel.recipient = "invalidrecipient"
        viewModel.amount = "100"

        let expectation = XCTestExpectation(description: "Waiting for transfer message to be updated")

        // When
        Task {
            do {
                try await self.viewModel.sendMoney()
                XCTFail("Expected sendMoney to fail due to invalid recipient")
            } catch MoneyTransferViewModel.MoneyTransferError.invalidRecipientOrAmount {
                expectation.fulfill()
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }

        wait(for: [expectation], timeout: 1.0)

        // Then
        XCTAssertEqual(viewModel.transferMessage, "Invalid recipient or amount")
    }

    func testSendMoneyWithSuccessfulTransfer() async throws {
        // Given
        viewModel.recipient = "valid@example.com"
        viewModel.amount = "100"
        mockAccountService.accountDetails = AccountDetail(currentBalance: 1234.56, transactions: [])

        // Création d'une attente pour la mise à jour asynchrone
        let expectation = XCTestExpectation(description: "Waiting for transfer message to be updated")

        // When
        Task {
            try await self.viewModel.sendMoney()
            expectation.fulfill()
        }

        // Attend que l'attente soit remplie
        wait(for: [expectation], timeout: 1.0)

        // Then
        XCTAssertEqual(viewModel.transferMessage, "Successfully transferred 100 to valid@example.com")
        XCTAssertEqual(mockAccountDetailViewModel.totalAmount, 1234.56)
    }

    func testSendMoneyWithTransferFailure() async throws {
        // Given
        viewModel.recipient = "valid@example.com"
        viewModel.amount = "100"
        mockAccountService.accountServiceError = AccountServiceError.missingToken

        let expectation = XCTestExpectation(description: "Waiting for transfer message to be updated")

        // When
        Task {
            do {
                try await self.viewModel.sendMoney()
                XCTFail("Expected sendMoney to fail due to transfer error")
            } catch MoneyTransferViewModel.MoneyTransferError.transferFailed {
                expectation.fulfill()
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }

        wait(for: [expectation], timeout: 1.0)

        // Then
        XCTAssertTrue(viewModel.transferMessage.starts(with: "Transfer failed"))
    }

}
