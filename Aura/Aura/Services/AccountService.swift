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
    enum AccountServiceError: Error, Equatable {
        case invalidCredentials
        case invalidResponse
        case unauthorized
        case missingToken
        case unknown
        case decodingError(DecodingError)
        case networkError(Error)
        case serverError

        static func ==(lhs: RemoteAccountService.AccountServiceError, rhs: RemoteAccountService.AccountServiceError) -> Bool {
            switch (lhs, rhs) {
            case (.invalidCredentials, .invalidCredentials),
                 (.invalidResponse, .invalidResponse),
                 (.unauthorized, .unauthorized),
                 (.missingToken, .missingToken),
                 (.unknown, .unknown),
                 (.serverError, .serverError):
                return true
            case (.decodingError(let lhsError), .decodingError(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            case (.networkError(let lhsError), .networkError(let rhsError)):
                return (lhsError as NSError).code == (rhsError as NSError).code
            default:
                return false
            }
        }
    }

    private static let url = URL(string: "http://127.0.0.1:8080/")!
    private var task: URLSessionDataTask?
    private var urlSession: URLSessionProtocol
    static var token: String?

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func logAccount() async throws -> AccountDetail {
        print("logAccount called")
        
        guard let token = RemoteAccountService.token else {
            throw AccountServiceError.missingToken
        }
        
        var request = URLRequest(url: RemoteAccountService.url.appendingPathComponent("account"))
        request.setValue(token, forHTTPHeaderField: "token")
        
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
                throw AccountServiceError.serverError
            default:
                throw AccountServiceError.invalidResponse
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

        guard let token = RemoteAccountService.token else {
            throw AccountServiceError.missingToken
        }
        
        var request = URLRequest(url: RemoteAccountService.url.appendingPathComponent("account/transfer"))
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "token")
        
        let transferInformation = TransferInformation(recipient: recipient, amount: amount)
        
        do {
            request.httpBody = try JSONEncoder().encode(transferInformation)
            
            let (_, response) = try await urlSession.data(for: request)
            
            guard let response = response as? HTTPURLResponse else {
                throw AccountServiceError.invalidResponse
            }

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
