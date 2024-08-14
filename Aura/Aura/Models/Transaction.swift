//
//  Transaction.swift
//  Aura
//
//  Created by Margot Pasquali on 16/07/2024.
//

import Foundation

// MARK: - AccountDetail

/// Modèle représentant les détails d'un compte.
///
/// Cette structure contient le solde actuel et la liste des transactions associées au compte.
struct AccountDetail: Codable {
    let currentBalance: Double
    let transactions: [Transaction]
}

// MARK: - Transaction

/// Modèle représentant une transaction.
///
/// Cette structure contient le libellé de la transaction ainsi que sa valeur.
struct Transaction: Codable, Equatable {
    let label: String
    let value: Double
}
