//
//  MockServices.swift
//  AuraTests
//
//  Created by Margot Pasquali on 05/08/2024.
//

import Foundation
@testable import Aura

struct MockAuthService: AuthService {
    static var token: String?
    static var authServiceError: RemoteAuthService.AuthServiceError?

    func authenticate(username: String, password: String) async throws {
        if let authServiceError = Self.authServiceError {
            throw authServiceError
        } else {
            Self.token = "FB24D136-C228-491D-AB30-FDFD97009D19"
        }
    }
}

struct MockAccountService: AccountService {
    static var accountServiceError: RemoteAccountService.AccountServiceError?
    static var accountDetails: AccountDetail = AccountDetail(currentBalance: 1234.56, transactions: [])

    func logAccount() async throws -> AccountDetail {
        if let accountServiceError = Self.accountServiceError {
            throw accountServiceError
        } else {
            return Self.accountDetails
        }
    }

    func createTransfer(recipient: String, amount: Float) async throws {
        // Mock implementation
    }
}
