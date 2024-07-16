//
//  Transaction.swift
//  Aura
//
//  Created by Margot Pasquali on 16/07/2024.
//

import Foundation

struct AccountDetail: Codable {
    let currentBalance: Double
    let transactions: [Transaction]
}

struct Transaction: Codable {
    let label: String
    let value: Double
}
