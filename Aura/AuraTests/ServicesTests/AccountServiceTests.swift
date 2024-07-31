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
        accountService = nil
        super.tearDown()
    }

    func testLogAccountSuccessful() async throws {
        // Given
        MockProtocol.requestHandler = { request in
            (FakeResponseData.responseOk, FakeResponseData.logAccountCorrectData)
        }

        RemoteAccountService.token = "FB24D136-C228-491D-AB30-FDFD97009D19"

        // When
        let accountDetail = try await accountService.logAccount()

        // Then
        XCTAssertEqual(accountDetail.currentBalance, 1234.56)
        XCTAssertEqual(accountDetail.transactions.count, 2)
    }
}
