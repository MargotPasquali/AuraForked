//
//  FakeResponseData.swift
//  AuraTests
//
//  Created by Margot Pasquali on 15/07/2024.
//

import Foundation

class FakeResponseData {
    static let responseOk = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    static let responseKo = HTTPURLResponse(url: URL(string: "http://127.0.0.1:8080/")!, statusCode: 500, httpVersion: nil, headerFields: nil)!
    
    class AuthError: Error {}
    static let error = AuthError()
    
    static var authCorrectData: Data {
        let bundle = Bundle(for: FakeResponseData.self)
        guard let url = bundle.url(forResource: "Auth", withExtension: "json") else {
            fatalError("Auth.json file not found")
        }
        return try! Data(contentsOf: url)
    }
    
    static var logAccountCorrectData: Data {
        let bundle = Bundle(for: FakeResponseData.self)
        guard let url = bundle.url(forResource: "AccountDetail", withExtension: "json") else {
            fatalError("AccountDetail.json file not found")
        }
        return try! Data(contentsOf: url)
    }
    
    static let authIncorrectData = "erreur".data(using: .utf8)!
}
