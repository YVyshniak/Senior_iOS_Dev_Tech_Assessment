//
//  LoginView.swift
//  Senior_iOS_Dev_Tech_Assessment
//
//  Created by Yaroslav on 09.06.2025.
//
import SwiftUI

struct LoginView: View {
    
    @StateObject var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Documents Vault")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Sign in to access your secure documents")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Enter your email", text: $viewModel.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        Group {
                            if viewModel.isPasswordVisible {
                                TextField("Enter your password", text: $viewModel.password)
                            } else {
                                SecureField("Enter your password", text: $viewModel.password)
                            }
                        }
                        .textContentType(.password)
                        
                        Button(action: { viewModel.isPasswordVisible.toggle() }) {
                            Image(systemName: viewModel.isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            
            if let errorMessage = viewModel.api.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                Task {
                    await viewModel.login()
                    if viewModel.api.isAuthenticated {
                        dismiss()
                    }
                }
            }) {
                HStack {
                    if viewModel.api.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text(viewModel.api.isLoading ? "Signing In..." : "Sign In")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            .disabled(viewModel.api.isLoading || viewModel.email.isEmpty || viewModel.password.isEmpty)
            
            VStack(spacing: 8) {
                Text("Test Credentials:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Username: emilys")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Password: emilyspass")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    LoginView(viewModel: LoginView.ViewModel())
}
