//
//  URLSessionProtocol.swift
//  Aura
//
//  Created by Margot Pasquali on 29/07/2024.
//

import Foundation

// MARK: - URLSessionProtocol

/// Protocole qui permet de créer une abstraction autour de `URLSession`
///
/// Ce protocole facilite le test en permettant de remplacer l'implémentation par une simulation lors des tests unitaires.
protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

// MARK: - URLSession Conformance

/// Extension de `URLSession` pour se conformer au protocole `URLSessionProtocol`.
///
/// Cette extension permet à `URLSession` de fonctionner directement là où un `URLSessionProtocol` est requis, facilitant ainsi l'injection de dépendances.
extension URLSession: URLSessionProtocol {}
