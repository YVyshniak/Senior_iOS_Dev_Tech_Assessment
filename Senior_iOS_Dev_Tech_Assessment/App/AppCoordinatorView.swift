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

