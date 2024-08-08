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
    private var urlSession: URLSession!

    override func setUp() {
        super.setUp()

        let urlSessionConfiguration = URLSessionConfiguration.ephemeral
        urlSessionConfiguration.protocolClasses = [MockProtocol.self]
        urlSession = URLSession(configuration: urlSessionConfiguration)

        accountService = MockAccountService()
        MockAuthService.reset()
        MockAccountService.reset()
    }

    override func tearDown() {
        MockProtocol.requestHandler = nil
        MockProtocol.error = nil
        accountService = nil
        MockAuthService.reset()
        MockAccountService.reset()
        super.tearDown()
    }

    func testLogAccountSuccessful() async throws {
        MockAccountService.token = "FB24D136-C228-491D-AB30-FDFD97009D19"
        MockProtocol.requestHandler = { request in
            print("Handling log account request: \(request)")
            return (FakeResponseData.responseOk, FakeResponseData.logAccountCorrectData)
        }

        do {
            let accountDetail = try await accountService.logAccount()
            XCTAssertEqual(accountDetail.currentBalance, 1234.56)
            XCTAssertEqual(accountDetail.transactions.count, 2)
        } catch let caughtError {
            XCTFail("Unexpected error: \(caughtError)")
        }
    }

    func testLogAccountWithInvalidToken() async throws {
        MockAccountService.token = "INVALID_TOKEN"
        MockProtocol.requestHandler = { request in
            print("Handling log account request with invalid token: \(request)")
            let response = HTTPURLResponse(url: request.url!, statusCode: 401, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        do {
            _ = try await accountService.logAccount()
            XCTFail("Expected account logging to fail due to invalid token")
        } catch RemoteAccountService.AccountServiceError.unauthorized {
            // Expected error
        } catch let caughtError {
            XCTFail("Unexpected error: \(caughtError)")
        }
    }

    func testLogAccountWithServerError() async throws {
        MockAccountService.token = "FB24D136-C228-491D-AB30-FDFD97009D19"
        MockProtocol.requestHandler = { request in
            print("Handling log account request with server error: \(request)")
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        do {
            _ = try await accountService.logAccount()
            XCTFail("Expected account logging to fail due to server error")
        } catch RemoteAccountService.AccountServiceError.serverError {
            // Expected error
        } catch let caughtError {
            XCTFail("Unexpected error: \(caughtError)")
        }
    }

    func testLogAccountWithNetworkError() async throws {
        MockAccountService.token = "FB24D136-C228-491D-AB30-FDFD97009D19"
        MockProtocol.error = URLError(.notConnectedToInternet)
        print("Testing logAccount with network error")

        do {
            _ = try await accountService.logAccount()
            XCTFail("Expected account logging to fail due to network error")
        } catch RemoteAccountService.AccountServiceError.networkError {
            // Expected error
        } catch let caughtError {
            XCTFail("Unexpected error: \(caughtError)")
        }
    }

    func testLogAccountWithInvalidData() async throws {
        MockAccountService.token = "FB24D136-C228-491D-AB30-FDFD97009D19"
        MockProtocol.requestHandler = { request in
            print("Handling log account request with invalid data: \(request)")
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, FakeResponseData.incorrectData)
        }

        do {
            _ = try await accountService.logAccount()
            XCTFail("Expected log account to fail due to invalid data")
        } catch RemoteAccountService.AccountServiceError.decodingError {
            // Expected error
        } catch let caughtError {
            XCTFail("Unexpected error: \(caughtError)")
        }
    }

    func testCreateTransferSuccessful() async throws {
        MockAccountService.token = "FB24D136-C228-491D-AB30-FDFD97009D19"
        MockProtocol.requestHandler = { request in
            print("Handling create transfer request: \(request)")
            return (FakeResponseData.responseOk, Data())
        }

        do {
            try await accountService.createTransfer(recipient: "recipient@example.com", amount: 100.0)
        } catch let caughtError {
            XCTFail("Unexpected error: \(caughtError)")
        }
    }

    func testCreateTransferWithInvalidToken() async throws {
        MockAccountService.token = "INVALID_TOKEN"
        MockProtocol.requestHandler = { request in
            print("Handling create transfer request with invalid token: \(request)")
            let response = HTTPURLResponse(url: request.url!, statusCode: 401, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        do {
            try await accountService.createTransfer(recipient: "recipient@example.com", amount: 100.0)
            XCTFail("Expected create transfer to fail due to invalid token")
        } catch RemoteAccountService.AccountServiceError.unauthorized {
            // Expected error
        } catch let caughtError {
            XCTFail("Unexpected error: \(caughtError)")
        }
    }

    func testCreateTransferWithServerError() async throws {
        MockAccountService.token = "FB24D136-C228-491D-AB30-FDFD97009D19"
        MockProtocol.requestHandler = { request in
            print("Handling create transfer request with server error: \(request)")
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        do {
            try await accountService.createTransfer(recipient: "recipient@example.com", amount: 100.0)
            XCTFail("Expected transfer to fail due to server error")
        } catch RemoteAccountService.AccountServiceError.serverError {
            // Expected error
        } catch let caughtError {
            XCTFail("Unexpected error: \(caughtError)")
        }
    }

    func testCreateTransferWithNetworkError() async throws {
        MockAccountService.token = "FB24D136-C228-491D-AB30-FDFD97009D19"
        MockProtocol.error = URLError(.notConnectedToInternet)
        print("Testing createTransfer with network error")

        do {
            try await accountService.createTransfer(recipient: "recipient@example.com", amount: 100.0)
            XCTFail("Expected create transfer to fail due to network error")
        } catch RemoteAccountService.AccountServiceError.networkError {
            // Expected error
        } catch let caughtError {
            XCTFail("Unexpected error: \(caughtError)")
        }
    }
}
