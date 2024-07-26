//
//  AuthServiceTests.swift
//  AuraTests
//
//  Created by Margot Pasquali on 17/07/2024.
//

@testable import Aura
import XCTest

//final class AuthServiceTests: XCTestCase {
//    
//    func testAuthService_WithCorrectData_ShouldReturnSuccess() async throws {
//        // Préparer les données de test
//        let session = URLSessionFake(data: FakeResponseData.authCorrectData, response: FakeResponseData.responseOk, error: nil)
//        let authService = AuthService(urlSession: session)
//        
//        // Charger le token attendu depuis Auth.json
//        let bundle = Bundle(for: type(of: self))
//        guard let url = bundle.url(forResource: "Auth", withExtension: "json"),
//              let data = try? Data(contentsOf: url),
//              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//              let expectedToken = json["token"] as? String else {
//            XCTFail("Failed to load token from Auth.json")
//            return
//        }
//        
//        // Exécuter le test
//        do {
//            try await authService.authenticate(username: "test@aura.app", password: "test123")
//            XCTAssertEqual(AuthService.token, expectedToken, "Token should match the one in Auth.json")
//        } catch {
//            XCTFail("Authentication failed with error: \(error)")
//        }
//    }
//}

