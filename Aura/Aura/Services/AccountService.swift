//
//  AccountService.swift
//  Aura
//
//  Created by Margot Pasquali on 30/07/2024.
//

import Foundation

protocol AccountService {
    func logAccount() async throws -> AccountDetail
    func createTransfer(recipient: String, amount: Float) async throws
}

enum AccountServiceError: Error {
    case invalidCredentials
    case invalidResponse
    case unauthorized
    case missingToken
    case unknown
    case decodingError(DecodingError)
    case networkError(Error)
    case serverError
}

final class RemoteAccountService: AccountService {
    private static let url = URL(string: "http://127.0.0.1:8080/")!
    private var task: URLSessionDataTask?

    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }

    func logAccount() async throws -> AccountDetail {
        print("logAccount called")
        
        var request = URLRequest(url: RemoteAccountService.url.appendingPathComponent("account"))
        
        do {
            let (data, response) = try await networkManager.data(for: request)

            do {
                return try JSONDecoder().decode(AccountDetail.self, from: data)
            } catch let decodingError as DecodingError {
                throw AccountServiceError.decodingError(decodingError)
            }
        } catch let error as AccountServiceError {
            print("AccountServiceError occurred: \(error)")
            throw error
        } catch {
            print("Network error occurred: \(error)")
            throw AccountServiceError.networkError(error)
        }
    }
    
    func createTransfer(recipient: String, amount: Float) async throws {
        print("createTransfer called with recipient: \(recipient) and amount: \(amount)")

        var request = URLRequest(url: RemoteAccountService.url.appendingPathComponent("account/transfer"))
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let transferInformation = TransferInformation(recipient: recipient, amount: amount)
        
        do {
            request.httpBody = try JSONEncoder().encode(transferInformation)
            
            let (_, response) = try await networkManager.data(for: request)

            switch response.statusCode {
            case 200:
                return
            case 401:
                throw AccountServiceError.unauthorized
            case 500...599:
                throw AccountServiceError.serverError
            default:
                throw AccountServiceError.invalidResponse
            }
        } catch let error as AccountServiceError {
            throw error
        } catch {
            throw AccountServiceError.networkError(error)
        }
    }
}
