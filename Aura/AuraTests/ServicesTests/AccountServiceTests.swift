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

        accountService = RemoteAccountService(urlSession: urlSession)
    }

    override func tearDown() {
        MockProtocol.requestHandler = nil
        MockProtocol.error = nil
        accountService = nil
        RemoteAccountService.token = nil
        super.tearDown()
    }

    func testLogAccountSuccessful() async throws {
        RemoteAccountService.token = "FB24D136-C228-491D-AB30-FDFD97009D19"
        MockProtocol.requestHandler = { request in
            print("Handling log account request: \(request)")
            return (FakeResponseData.responseOk, FakeResponseData.logAccountCorrectData)
        }

        do {
            let accountDetail = try await accountService.logAccount()
            XCTAssertEqual(accountDetail.currentBalance, 1234.56)
            XCTAssertEqual(accountDetail.transactions.count, 2)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testLogAccountWithInvalidToken() async throws {
        RemoteAccountService.token = "INVALID_TOKEN"
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
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testLogAccountWithServerError() async throws {
        RemoteAccountService.token = "FB24D136-C228-491D-AB30-FDFD97009D19"
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
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testLogAccountWithNetworkError() async throws {
        RemoteAccountService.token = "FB24D136-C228-491D-AB30-FDFD97009D19"
        MockProtocol.error = URLError(.notConnectedToInternet)

        do {
            _ = try await accountService.logAccount()
            XCTFail("Expected account logging to fail due to network error")
        } catch RemoteAccountService.AccountServiceError.networkError {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testLogAccountWithInvalidData() async throws {
        RemoteAccountService.token = "FB24D136-C228-491D-AB30-FDFD97009D19"
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
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testCreateTransferSuccessful() async throws {
        RemoteAccountService.token = "FB24D136-C228-491D-AB30-FDFD97009D19"
        MockProtocol.requestHandler = { request in
            print("Handling create transfer request: \(request)")
            return (FakeResponseData.responseOk, Data())
        }

        do {
            try await accountService.createTransfer(recipient: "recipient@example.com", amount: 100.0)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testCreateTransferWithInvalidToken() async throws {
        RemoteAccountService.token = "INVALID_TOKEN"
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
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testCreateTransferWithServerError() async throws {
        RemoteAccountService.token = "FB24D136-C228-491D-AB30-FDFD97009D19"
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
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testCreateTransferWithNetworkError() async throws {
        RemoteAccountService.token = "FB24D136-C228-491D-AB30-FDFD97009D19"
        MockProtocol.error = URLError(.notConnectedToInternet)

        do {
            try await accountService.createTransfer(recipient: "recipient@example.com", amount: 100.0)
            XCTFail("Expected create transfer to fail due to network error")
        } catch RemoteAccountService.AccountServiceError.networkError {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
