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

final class RemoteAccountService: AccountService {
    
    enum AccountServiceError: Error {
        case invalidCredentials
        case invalidResponse
        case unauthorized
        case missingToken
        case unknown
        case decodingError(DecodingError)
        case networkError(Error)
        case serverError // Ajout du cas serverError
    }

    private static let url = URL(string: "http://127.0.0.1:8080/")!

    static var token: String?

    private var task: URLSessionDataTask?
    private var urlSession: URLSessionProtocol
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func logAccount() async throws -> AccountDetail {
        print("logAccount called")
        guard let token = RemoteAccountService.token else {
            throw AccountServiceError.missingToken
        }
        
        var request = URLRequest(url: RemoteAccountService.url.appendingPathComponent("account"))
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let response = response as? HTTPURLResponse else {
                throw AccountServiceError.invalidResponse
            }

            switch response.statusCode {
            case 200:
                do {
                    return try JSONDecoder().decode(AccountDetail.self, from: data)
                } catch let decodingError as DecodingError {
                    throw AccountServiceError.decodingError(decodingError)
                }
            case 401:
                throw AccountServiceError.unauthorized
            case 500...599:
                throw AccountServiceError.serverError // Utilisation de serverError
            default:
                throw AccountServiceError.invalidResponse
            }
        } catch let error as URLError {
            throw AccountServiceError.networkError(error)
        } catch let error as AccountServiceError {
            throw error
        } catch {
            throw AccountServiceError.unknown
        }
    }
    
    func createTransfer(recipient: String, amount: Float) async throws {
        print("createTransfer called with recipient: \(recipient) and amount: \(amount)")
        guard let token = RemoteAccountService.token else {
            throw AccountServiceError.missingToken
        }
        
        var request = URLRequest(url: RemoteAccountService.url.appendingPathComponent("account/transfer"))
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let transferInformation = TransferInformation(recipient: recipient, amount: amount)
        
        do {
            request.httpBody = try JSONEncoder().encode(transferInformation)
            
            let (data, response) = try await urlSession.data(for: request)
            
            guard let response = response as? HTTPURLResponse else {
                throw AccountServiceError.invalidResponse
            }

            switch response.statusCode {
            case 200:
                return
            case 401:
                throw AccountServiceError.unauthorized
            case 500...599:
                throw AccountServiceError.serverError // Utilisation de serverError
            default:
                throw AccountServiceError.invalidResponse
            }
        } catch let error as URLError {
            throw AccountServiceError.networkError(error)
        } catch let error as AccountServiceError {
            throw error
        } catch {
            throw AccountServiceError.unknown
        }
    }
}

