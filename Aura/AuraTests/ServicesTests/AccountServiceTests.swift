//
//  AccountServiceTests.swift
//  AuraTests
//
//  Created by Margot Pasquali on 31/07/2024.
//

import XCTest
@testable import Aura

// MARK: - AccountServiceTests

/// Tests unitaires pour `AccountService`.
///
/// Cette classe de tests vérifie les différentes fonctionnalités du `AccountService`,
/// telles que la récupération des détails du compte, la gestion des erreurs de réseau, et la création de transferts.
class AccountServiceTests: XCTestCase {
    
    // MARK: - Properties
    
    var accountService: AccountService!
    var mockNetworkManager: MockNetworkManager!
    
    // MARK: - Setup & Teardown
    
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
    
    // MARK: - Test Cases
    
    /// Teste la récupération réussie des détails du compte.
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
    
    /// Teste la récupération des détails du compte avec un jeton invalide.
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
    
    /// Teste la récupération des détails du compte avec une erreur de serveur.
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
    
    /// Teste la récupération des détails du compte avec une erreur de réseau.
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
    
    /// Teste la récupération des détails du compte avec des données incorrectes.
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
    
    /// Teste la création réussie d'un transfert.
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
    
    /// Teste la création d'un transfert avec un jeton invalide.
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
    
    /// Teste la création d'un transfert avec une erreur de serveur.
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
    
    /// Teste la création d'un transfert avec une erreur de réseau.
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
