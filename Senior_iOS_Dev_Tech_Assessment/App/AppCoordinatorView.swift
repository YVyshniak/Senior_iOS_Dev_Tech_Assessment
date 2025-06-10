//
//  AppCoordinatorView.swift
//  Senior_iOS_Dev_Tech_Assessment
//
//  Created by Yaroslav on 05.06.2025.
//
import SwiftUI

struct AppCoordinatorView: View {
    @StateObject private var securityManager = SecurityManager()
    @StateObject private var appLifecycleManager = AppLifecycleManager()
    @StateObject private var authManager = APIAuth.shared
    
    var body: some View {
        Group {
            if securityManager.isJailbroken {
                securityWarningView
            } else if appLifecycleManager.isInBackground {
                privacyBlurView
            }  else if securityManager.isUnlocked {
                MainContentView(authManager: authManager)
            } else {
                AuthenticationView(securityManager: securityManager)
            }
        }
        .task {
            if !securityManager.isJailbroken && !securityManager.isUnlocked {
                await securityManager.authenticateUser()
            }
        }
    }
    
    var securityWarningView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Security Warning")
                .font(.title)
                .fontWeight(.bold)
            
            Text("This device appears to be jailbroken. For your security, the Smart Documents Vault cannot run on compromised devices.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Please use a secure, non-jailbroken device to access your documents.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
    
    var privacyBlurView: some View {
        ZStack {
            Color.black
            
            VStack(spacing: 20) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                Text("Smart Documents Vault")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Protected")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

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
