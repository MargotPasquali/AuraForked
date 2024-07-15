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
    
    private static let baseURL = URL(string: "http://127.0.0.1:8080/")!
    private static var token: String?
    
    private var task: URLSessionDataTask?
    private var authSession = URLSession(configuration: .default)
    
    init(authSession: URLSession) {
        self.authSession = authSession
    }
    
    func getAuth(username: String, password: String, completionHandler: @escaping (Data?, Error?) -> Void) {
        var request = URLRequest(url: AuthService.baseURL.appendingPathComponent("auth"))
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
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let keytoken = json["token"] as? String {
                        AuthService.token = keytoken
                        print("Token received: \(keytoken)") // Debug: Print token
                        completionHandler(data, nil)
                    } else {
                        completionHandler(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid token received"]))
                    }
                } catch {
                    completionHandler(nil, error)
                }
            }
        }
        task?.resume()
    }
    
    func logAccount(completionHandler: @escaping (Data?, Error?) -> Void) {
        guard let token = AuthService.token else {
            print("Error in logAccount: No token available")
            completionHandler(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No token available"]))
            return
        }
        
        var request = URLRequest(url: AuthService.baseURL.appendingPathComponent("account"))
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("Error in logAccount: Invalid response status code \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                    completionHandler(nil, NSError(domain: "", code: (response as? HTTPURLResponse)?.statusCode ?? 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response status code"]))
                    return
                }
                print("logAccount successful with data: \(data)") // Debug: Print success
                completionHandler(data, nil)
            }
        }
        task?.resume()
    }
    
    func createTransfer(recipient: String, amount: Float, completionHandler: @escaping (Data?, Error?) -> Void) {
        guard let token = AuthService.token else {
            print("Error in createTransfer: No token available")
            completionHandler(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No token available"]))
            return
        }

        var request = URLRequest(url: AuthService.baseURL.appendingPathComponent("transfer"))
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let transferInformation = TransferInformation(recipient: recipient, amount: amount)
        do {
            request.httpBody = try JSONEncoder().encode(transferInformation)
        } catch {
            print("Failed to encode JSON: \(error.localizedDescription)")
            completionHandler(nil, error)
            return
        }
        
        task?.cancel()
        task = authSession.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error in createTransfer: \(error.localizedDescription)")
                    completionHandler(nil, error)
                    return
                }
                guard let data = data else {
                    print("Error in createTransfer: No data received")
                    completionHandler(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                    return
                }
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("Error in createTransfer: Invalid response status code \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                    completionHandler(nil, NSError(domain: "", code: (response as? HTTPURLResponse)?.statusCode ?? 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response status code"]))
                    return
                }
                completionHandler(data, nil)
            }
        }
        task?.resume()
    }
}
