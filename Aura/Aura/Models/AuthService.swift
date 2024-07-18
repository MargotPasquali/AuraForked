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
    static var shared = AuthService(authSession: URLSession.shared, accountSession: URLSession.shared) // singleton
        
        private static let url = URL(string: "http://127.0.0.1:8080/")!
        private static var token: String?
        
        private var task: URLSessionDataTask?
        private var authSession: URLSession
        private var accountSession: URLSession
        
        init(authSession: URLSession, accountSession: URLSession) {
            self.authSession = authSession
            self.accountSession = accountSession
        }
    
    func getAuth(username: String, password: String, completionHandler: @escaping (Data?, Error?) -> Void) {
        print("getAuth called with username: \(username) and password: \(password)")
        var request = URLRequest(url: AuthService.url.appendingPathComponent("auth"))
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let emailAndPassword = AuthenticationRequest(username: username, password: password)
        do {
            request.httpBody = try JSONEncoder().encode(emailAndPassword)
        } catch {
            print("Failed to encode JSON: \(error.localizedDescription)")
            completionHandler(nil, error)
            return
        }
        
        task?.cancel()
        task = authSession.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error in getAuth: \(error.localizedDescription)")
                    completionHandler(nil, error)
                    return
                }
                guard let data = data else {
                    print("Error in getAuth: No data received")
                    completionHandler(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                    return
                }
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("Error in getAuth: Invalid response status code \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                    completionHandler(nil, NSError(domain: "", code: (response as? HTTPURLResponse)?.statusCode ?? 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response status code"]))
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], // conversion into swift objects
                       let keytoken = json["token"] as? String {
                        AuthService.token = keytoken
                        print("Token received: \(keytoken)")
                        completionHandler(data, nil)
                    } else {
                        print("Error in getAuth: Invalid token received")
                        completionHandler(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid token received"]))
                    }
                } catch {
                    print("Error in getAuth: \(error.localizedDescription)")
                    completionHandler(nil, error)
                }
            }
        }
        task?.resume()
    }
    
    func logAccount(completionHandler: @escaping (AccountDetail?, Error?) -> Void) {
        print("logAccount called")
        guard let token = AuthService.token else {
            let noTokenError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No token available"])
            print("Error in logAccount: \(noTokenError.localizedDescription)")
            completionHandler(nil, noTokenError)
            return
        }
        
        var request = URLRequest(url: AuthService.url.appendingPathComponent("account"))
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "token")
        
        task?.cancel()
        task = authSession.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error in logAccount: \(error.localizedDescription)")
                    completionHandler(nil, error)
                    return
                }
                guard let data = data else {
                    print("Error in logAccount: No data received")
                    completionHandler(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                    return
                }
                print("Raw JSON data received: \(String(data: data, encoding: .utf8) ?? "")")
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("Error in logAccount: Invalid response status code \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                    completionHandler(nil, NSError(domain: "", code: (response as? HTTPURLResponse)?.statusCode ?? 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response status code"]))
                    return
                }
                
                do {
                    let accountDetail = try JSONDecoder().decode(AccountDetail.self, from: data)
                    print("Account detail received: \(accountDetail)")
                    completionHandler(accountDetail, nil)
                } catch {
                    print("Error decoding JSON in logAccount: \(error.localizedDescription)")
                    completionHandler(nil, error)
                }
            }
        }
        task?.resume()
    }
    
    func createTransfer(recipient: String, amount: Float, completionHandler: @escaping (Error?) -> Void) {
        print("createTransfer called with recipient: \(recipient) and amount: \(amount)")
        guard let token = AuthService.token else {
            let noTokenError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No token available"])
            print("Error in createTransfer: \(noTokenError.localizedDescription)")
            completionHandler(noTokenError)
            return
        }
        
        var request = URLRequest(url: AuthService.url.appendingPathComponent("account/transfer"))
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "token")
        
        let transferInformation = TransferInformation(recipient: recipient, amount: amount)
        do {
            request.httpBody = try JSONEncoder().encode(transferInformation)
        } catch {
            print("Failed to encode JSON: \(error.localizedDescription)")
            completionHandler(error)
            return
        }
        
        task?.cancel()
        task = authSession.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error in createTransfer: \(error.localizedDescription)")
                    completionHandler(error)
                    return
                }
                guard let data = data else {
                    print("Error in createTransfer: No data received")
                    completionHandler(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                    return
                }
                guard let response = response as? HTTPURLResponse else {
                    print("Error in createTransfer: Invalid response format")
                    completionHandler(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"]))
                    return
                }
                
                print("Response status code: \(response.statusCode)")
                print("Response data: \(String(data: data, encoding: .utf8) ?? "No data")")
                
                if response.statusCode == 200 {
                    completionHandler(nil)
                } else {
                    let statusCodeError = NSError(domain: "", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "Invalid response status code"])
                    print("Error in createTransfer: \(statusCodeError.localizedDescription)")
                    completionHandler(statusCodeError)
                }
            }
        }
        task?.resume()
    }
}
