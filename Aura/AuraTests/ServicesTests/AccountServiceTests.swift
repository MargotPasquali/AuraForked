//
//  AccountServiceTests.swift
//  AuraTests
//
//  Created by Margot Pasquali on 31/07/2024.
//

import XCTest
@testable import Aura

class AccountServiceTests: XCTestCase {

    var accountService: AccountService!
    var mockNetworkManager: MockNetworkManager!

    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        accountService = RemoteAccountService(networkManager: mockNetworkManager)
    }

    override func tearDown() {
        mockNetworkManager = nil
        accountService = nil
        super.tearDown()
    }

    func testLogAccountSuccessful() async throws {
        // Given
        mockNetworkManager.response = FakeResponseData.responseOk
        mockNetworkManager.responseData = FakeResponseData.logAccountCorrectData
        mockNetworkManager.error = nil

        // When
        do {
            let accountDetail = try await accountService.logAccount()
            
            // Then
            XCTAssertEqual(accountDetail.currentBalance, 1234.56)
            XCTAssertEqual(accountDetail.transactions.count, 2)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testLogAccountWithInvalidToken() async throws {
        // Given
        mockNetworkManager.response = FakeResponseData.responseWithInvalidToken
        mockNetworkManager.responseData = Data()
        mockNetworkManager.error = nil

        // When
        do {
            _ = try await accountService.logAccount()
            XCTFail("Expected account logging to fail due to invalid token")
        } catch AuthServiceError.unauthorized {
            // Then
            print("Caught expected AuthServiceError.unauthorized")
        } catch {
            print("Unexpected error: \(error)")
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testLogAccountWithServerError() async throws {
        // Given
        mockNetworkManager.response = FakeResponseData.responseKo
        mockNetworkManager.responseData = Data()
        mockNetworkManager.error = nil

        // When
        do {
            _ = try await accountService.logAccount()
            XCTFail("Expected account logging to fail due to server error")
        } catch AuthServiceError.serverError {
            // Then
            print("Caught expected AuthServiceError.serverError")
        } catch {
            print("Unexpected error: \(error)")
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testLogAccountWithNetworkError() async throws {
            // Given
            let networkError = URLError(.notConnectedToInternet)
            mockNetworkManager.error = networkError
            print("Configured mock network error: \(networkError)")

            // When
            do {
                _ = try await accountService.logAccount()
                XCTFail("Expected account logging to fail due to network error")
            } catch AuthServiceError.networkError(let error) {
                // Then
                XCTAssertEqual((error as? URLError)?.code, networkError.code)
                print("Caught expected AuthServiceError.networkError: \(error)")
            } catch {
                print("Unexpected error: \(error)")
                XCTFail("Unexpected error: \(error)")
            }
        }

    func testLogAccountWithInvalidData() async throws {
        // Given
        mockNetworkManager.response = FakeResponseData.responseOk
        mockNetworkManager.responseData = FakeResponseData.incorrectData
        mockNetworkManager.error = nil

        // When
        do {
            _ = try await accountService.logAccount()
            XCTFail("Expected log account to fail due to invalid data")
        } catch AuthServiceError.decodingError(let error) {
            // Then
            print("Caught expected AuthServiceError.decodingError: \(error)")
        } catch {
            print("Unexpected error: \(error)")
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testCreateTransferSuccessful() async throws {
        // Given
        mockNetworkManager.response = FakeResponseData.responseOk
        mockNetworkManager.responseData = Data()
        mockNetworkManager.error = nil

        // When
        do {
            try await accountService.createTransfer(recipient: "recipient@example.com", amount: 100.0)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testCreateTransferWithInvalidToken() async throws {
        // Given
        mockNetworkManager.response = FakeResponseData.responseWithInvalidToken
        mockNetworkManager.responseData = Data()
        mockNetworkManager.error = nil

        // When
        do {
            try await accountService.createTransfer(recipient: "recipient@example.com", amount: 100.0)
            XCTFail("Expected create transfer to fail due to invalid token")
        } catch AuthServiceError.unauthorized {
            // Then
            print("Caught expected AuthServiceError.unauthorized")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testCreateTransferWithServerError() async throws {
        // Given
        mockNetworkManager.response = FakeResponseData.responseKo
        mockNetworkManager.responseData = Data()
        mockNetworkManager.error = nil

        // When
        do {
            try await accountService.createTransfer(recipient: "recipient@example.com", amount: 100.0)
            XCTFail("Expected transfer to fail due to server error")
        } catch AuthServiceError.serverError {
            // Then
            print("Caught expected AuthServiceError.serverError")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testCreateTransferWithNetworkError() async throws {
        // Given
        mockNetworkManager.error = URLError(.notConnectedToInternet)

        // When
        do {
            try await accountService.createTransfer(recipient: "recipient@example.com", amount: 100.0)
            XCTFail("Expected create transfer to fail due to network error")
        } catch AuthServiceError.networkError(let error) {
            // Then
            print("Caught expected AuthServiceError.networkError: \(error)")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
