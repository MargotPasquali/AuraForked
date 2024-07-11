//
//  AuthService.swift
//  Aura
//
//  Created by Margot Pasquali on 11/07/2024.
//

import Foundation

struct AuthenticationRequest: Encodable {
    let username: String
    let password: String
}

struct TransferInformation: Encodable {
    let recipient: String
    let amount: Float
}

class AuthService {
    static var shared = AuthService()
    private init() {}
    
    private static let url = URL(string: "http://127.0.0.1:8080/")!
    private static let token = "FB24D136-C228-491D-AB30-FDFD97009D19"
    
    private var task: URLSessionDataTask?
    private var authSession = URLSession(configuration: .default)
    
    init(authSession: URLSession) {
        self.authSession = authSession
    }
    
    func logAccount(completionHandler: @escaping (Data?) -> Void) {
        var request = URLRequest(url: AuthService.url)
        request.httpMethod = "GET"
        
        let body = "account"
        request.httpBody = body.data(using: .utf8)
        
        request.setValue(AuthService.token, forHTTPHeaderField: "token")
        
        task?.cancel()
        task = authSession.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    completionHandler(nil)
                    return
                }
                guard let data = data else {
                    print("Error: No data received")
                    completionHandler(nil)
                    return
                }
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("Error: Invalid reponse status code \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                    completionHandler(nil)
                    return
                }
                completionHandler(data)
            }
        }
        task?.resume()
    }

    func getAuth(completionHandler: @escaping (Data?) -> Void) {
        var request = URLRequest(url: AuthService.url)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let emailAndPassword = AuthenticationRequest(username: "test@aura.app", password: "test123")
        do {
            request.httpBody = try JSONEncoder().encode(emailAndPassword)
        } catch {
            print("Failed to encode JSON: \(error.localizedDescription)")
            completionHandler(nil)
            return
        }
        
        task?.cancel()
        task = authSession.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    completionHandler(nil)
                    return
                }
                guard let data = data else {
                    print("Error: No data received")
                    completionHandler(nil)
                    return
                }
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("Error: Invalid response status code \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                    completionHandler(nil)
                    return
                }
                completionHandler(data)
            }
        }
        task?.resume()
    }
    
    func createTransfer(completionHandler: @escaping (Data?) -> Void) {
        var request = URLRequest(url: AuthService.url)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(AuthService.token, forHTTPHeaderField: "token")
        
        let transferinformation = TransferInformation(recipient: "+33 6 01 02 03 04", amount: 12.4)
        do {
            request.httpBody = try JSONEncoder().encode(transferinformation)
        } catch {
            print("Failed to encode JSON: \(error.localizedDescription)")
            completionHandler(nil)
            return
        }
        
        task?.cancel()
        task = authSession.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    completionHandler(nil)
                    return
                }
                guard let data = data else {
                    print("Error: No data received")
                    completionHandler(nil)
                    return
                }
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("Error: Invalid response status code \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                    completionHandler(nil)
                    return
                }
                completionHandler(data)
            }
        }
        task?.resume()
    }
}
