//
//  AuthenticationView.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import SwiftUI

// MARK: - AuthenticationView

/// Vue de l'authentification de l'utilisateur.
///
/// Cette vue affiche un formulaire d'authentification permettant à l'utilisateur de saisir son adresse email et son mot de passe, puis de se connecter.
struct AuthenticationView: View {
    
    // MARK: - State Properties
    
    @State private var username: String = ""
    @State private var password: String = ""
    
    // MARK: - Gradient Colors
    
    let gradientStart = Color(hex: "#94A684").opacity(0.7)
    let gradientEnd = Color(hex: "#94A684").opacity(0.0) // Dégradé vers transparent
    
    // MARK: - Observed Object
    
    @ObservedObject var viewModel: AuthenticationViewModel
    @State private var showDestination = false
    
    // MARK: - Body
    
    var body: some View {
        
        ZStack {
            // MARK: - Background Gradient
            
            // Dégradé de fond
            LinearGradient(gradient: Gradient(colors: [gradientStart, gradientEnd]), startPoint: .top, endPoint: .bottomLeading)
                .edgesIgnoringSafeArea(.all)
            
            // MARK: - Authentication Form
            
            VStack(spacing: 20) {
                Image(systemName: "person.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                
                Text("Welcome !")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                TextField("Adresse email", text: $viewModel.username)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
                
                SecureField("Mot de passe", text: $viewModel.password)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                
                // MARK: - Error Message
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                // MARK: - Login Button
                
                Button(action: {
                    Task {
                        try await viewModel.login()
                    }
                }) {
                    Text("Se connecter")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 40)
        }
        .onTapGesture {
            self.endEditing(true)  // Cela permet de cacher le clavier en tapant à l'extérieur
        }
        
    }
    
}

// MARK: - Preview

#Preview {
    AuthenticationView(viewModel: AuthenticationViewModel())
}
