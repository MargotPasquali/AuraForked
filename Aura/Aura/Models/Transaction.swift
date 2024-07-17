//
//  Transaction.swift
//  Aura
//
//  Created by Margot Pasquali on 16/07/2024.
//

import Foundation

struct AccountDetail: Decodable {
    let currentBalance: Double
    let transactions: [Transaction]
}

struct Transaction: Decodable, Identifiable {
    let id = UUID()
    let label: String
    let value: Double
}
