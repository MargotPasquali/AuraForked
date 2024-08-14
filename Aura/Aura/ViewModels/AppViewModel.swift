//
//  AppViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

// MARK: - AppViewModel

/// ViewModel principal de l'application.
///
/// Cette classe gère l'état de connexion de l'utilisateur et fournit des ViewModels pour l'authentification et les détails du compte.
class AppViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Indicateur de l'état de connexion de l'utilisateur.
    @Published var isLogged: Bool
    
    // MARK: - Init
    
    /// Initialisation de `AppViewModel` avec un état de connexion non connecté par défaut.
    init() {
        isLogged = false
    }
    
    // MARK: - Computed Properties
    
    /// ViewModel pour la gestion de l'authentification.
    ///
    /// Ce ViewModel est initialisé avec une closure qui met à jour l'état de connexion lorsqu'une authentification réussit.
    var authenticationViewModel: AuthenticationViewModel {
        return AuthenticationViewModel { [weak self] _ in
            self?.isLogged = true
        }
    }
    
    /// ViewModel pour la gestion des détails du compte.
    var accountDetailViewModel: AccountDetailViewModel {
        return AccountDetailViewModel()
    }
}
