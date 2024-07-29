//
//  AuthServiceProtocol.swift
//  Aura
//
//  Created by Margot Pasquali on 29/07/2024.
//

import Foundation

protocol AuthServiceProtocol {
    func authenticate(username: String, password: String) async throws -> String
    func logAccount() async throws -> AccountDetail
    func createTransfer(recipient: String, amount: Float) async throws
}

