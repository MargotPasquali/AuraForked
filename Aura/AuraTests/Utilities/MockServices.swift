//
//  MockServices.swift
//  AuraTests
//
//  Created by Margot Pasquali on 05/08/2024.
//

import Foundation
@testable import Aura

final class MockAuthService: AuthService {

    let networkManager: NetworkManager

    var authServiceError: AuthServiceError?

    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }

    func authenticate(username: String, password: String) async throws {
        if let authServiceError = authServiceError {
            throw authServiceError
        } else {
            NetworkManager.shared.set(token: "FB24D136-C228-491D-AB30-FDFD97009D19")
        }
    }
}

final class MockAccountService: AccountService {

    var accountServiceError: AccountServiceError?
    
    var accountDetails: AccountDetail = AccountDetail(currentBalance: 1234.56, transactions: [])

    func logAccount() async throws -> AccountDetail {
        if let accountServiceError = accountServiceError {
            throw accountServiceError
        } else {
            return accountDetails
        }
    }

    func createTransfer(recipient: String, amount: Float) async throws {
        if let accountServiceError = accountServiceError {
            throw accountServiceError
        }
    }

    func setup() {
        accountDetails = AccountDetail(currentBalance: 1234.56, transactions: [])
    }
}
