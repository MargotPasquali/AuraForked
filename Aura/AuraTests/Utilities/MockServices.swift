//
//  MockServices.swift
//  AuraTests
//
//  Created by Margot Pasquali on 05/08/2024.
//

import Foundation
@testable import Aura


final class MockAuthService: AuthService {
    var networkManager: NetworkManagerProtocol
    
    var authResponse: AuthenticationResponse?
    var error: AuthServiceError?
    
    required init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func authenticate(username: String, password: String) async throws {
        if let error = error {
            throw error
        }
        
        if let authResponse = authResponse {
            networkManager.set(token: authResponse.token)
        } else {
            throw AuthServiceError.unknown
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
