//
//  AuthenticationView.swift
//  Senior_iOS_Dev_Tech_Assessment
//
//  Created by Yaroslav on 11.06.2025.
//
import SwiftUI

struct AuthenticationView: View {
    let securityManager: SecurityManager
    @State private var isAuthenticating = false
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            VStack(spacing: 10) {
                Text("Smart Documents Vault")
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            Button(action: authenticate) {
                HStack {
                    if isAuthenticating {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "faceid")
                    }
                    Text(isAuthenticating ? "Authenticating..." : "Unlock Vault")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            .disabled(isAuthenticating)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    private func authenticate() {
        isAuthenticating = true
        Task {
            await securityManager.authenticateUser()
            await MainActor.run {
                isAuthenticating = false
            }
        }
    }
}
