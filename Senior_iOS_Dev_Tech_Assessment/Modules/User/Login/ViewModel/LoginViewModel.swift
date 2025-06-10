//
//  LoginViewModel.swift
//  Senior_iOS_Dev_Tech_Assessment
//
//  Created by Yaroslav on 09.06.2025.
//
import Foundation
import SwiftUI

extension LoginView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published var email = ""
        @Published var password = ""
        @Published var isPasswordVisible = false
        @Published var api = APIAuth.shared
        
        init() {
            
        }
        
        func login() async {
            let encodedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
            
            await api.login(email: email, password: encodedPassword)
        }
    }
}
