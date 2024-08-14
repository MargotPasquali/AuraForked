//
//  MoneyTransferView.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import SwiftUI

// MARK: - MoneyTransferView

/// Vue pour l'envoi d'argent à un destinataire.
///
/// Cette vue permet à l'utilisateur de saisir les informations du destinataire et le montant à transférer, puis d'initier le transfert.
struct MoneyTransferView: View {
    
    // MARK: - Observed Object
    
    @ObservedObject var viewModel = MoneyTransferViewModel(accountDetailViewModel: AccountDetailViewModel())
    
    // MARK: - State Properties
    
    @State private var animationScale: CGFloat = 1.0
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            
            // MARK: - Header Image
            
            // Ajout d'une image d'en-tête animée
            Image(systemName: "arrow.right.arrow.left.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(Color(hex: "#94A684"))
                .padding()
                .scaleEffect(animationScale)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                        animationScale = 1.2
                    }
                }
            
            // MARK: - Title
            
            Text("Send Money!")
                .font(.largeTitle)
                .fontWeight(.heavy)
            
            // MARK: - Recipient Input
            
            VStack(alignment: .leading) {
                Text("Recipient (Email or Phone)")
                    .font(.headline)
                TextField("Enter recipient's info", text: $viewModel.recipient)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .keyboardType(.emailAddress)
            }
            
            // MARK: - Amount Input
            
            VStack(alignment: .leading) {
                Text("Amount (€)")
                    .font(.headline)
                TextField("0.00", text: $viewModel.amount)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .keyboardType(.decimalPad)
            }
            
            // MARK: - Send Button
            
            Button(action: {
                Task {
                    try await viewModel.sendMoney()
                }
            }) {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                    Text("Send")
                }
                .padding()
                .background(Color(hex: "#94A684"))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            
            // MARK: - Transfer Message
            
            if !viewModel.transferMessage.isEmpty {
                Text(viewModel.transferMessage)
                    .padding(.top, 20)
                    .transition(.move(edge: .top))
            }
            
            Spacer()
        }
        .padding()
        .onTapGesture {
            self.endEditing(true)  // Cela permettra de cacher le clavier en tapant à l'extérieur
        }
    }
}

// MARK: - Preview

#Preview {
    MoneyTransferView()
}
