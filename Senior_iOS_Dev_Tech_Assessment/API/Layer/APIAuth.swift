//
//  APIAuth.swift
//  Senior_iOS_Dev_Tech_Assessment
//
//  Created by Yaroslav on 09.06.2025.
//
import SwiftUI
import Network

@MainActor
final class APIAuth: ObservableObject {
    static let shared = APIAuth()
    
    @Published var isAuthenticated = false
    @Published var currentUser: UserModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var tokenRefreshTask: Task<Void, Never>?
    private var loginTask: Task<Void, Never>?
    private var tokenExpiryDate: Date?
    private let maxRetryAttempts = 3
    
    private init() {
        Task {
            await checkAuthStatus()
        }
    }
    
    func login(email: String, password: String) async {
        loginTask?.cancel()
        
        loginTask = Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let loginRequest = LoginRequest(username: email, password: password)
                let requestData = try JSONEncoder().encode(loginRequest)
                
                let response: LoginResponse = try await APILayer.shared.request(
                    endpoint: "/auth/login",
                    method: .POST,
                    body: requestData,
                    responseType: LoginResponse.self
                )
                
                // Store tokens and user info
                try await KeychainManager.shared.saveToken(response.accessToken)
                try await KeychainManager.shared.saveRefreshToken(response.refreshToken)
                
                let user = UserModel(
                    id: response.id,
                    username: response.username,
                    email: response.email,
                    firstName: response.firstName,
                    lastName: response.lastName,
                    gender: response.gender,
                    image: response.image
                )
                
                try await KeychainManager.shared.saveUser(user)
                
                // Set token expiry to 30 minutes from now
                tokenExpiryDate = Date().addingTimeInterval(30 * 60)
                
                currentUser = user
                isAuthenticated = true
                
                scheduleTokenRefresh(expiresIn: 30 * 60)
                scheduleSessionTimeout(expiresIn: 30 * 60)
                
            } catch let error as APIError {
                errorMessage = error.errorDescription
            } catch {
                errorMessage = "Login failed. Please try again."
            }
            
            isLoading = false
        }
        
        await loginTask?.value
    }
    
    func logout() async {
        if let token = try? await KeychainManager.shared.loadToken() {
            do {

                let _: EmptyResponse = try await APILayer.shared.request(
                    endpoint: "/auth/logout",
                    method: .POST,
                    headers: ["Authorization" : "Bearer \(token)"],
                    responseType: EmptyResponse.self
                )
            } catch {
            }
        }

        tokenRefreshTask?.cancel()
        loginTask?.cancel()
        await KeychainManager.shared.clearAll()
        currentUser = nil
        isAuthenticated = false
        tokenExpiryDate = nil
        tokenRefreshTask = nil
    }

    
    private func checkAuthStatus() async {
        do {
            guard let token = try await KeychainManager.shared.loadToken(),
                  let user = try await KeychainManager.shared.loadUser() else {
                return
            }
            
            if await isTokenValid(token) {
                currentUser = user
                isAuthenticated = true
                
                if let expiryDate = tokenExpiryDate,
                   expiryDate > Date() {
                    let timeUntilExpiry = expiryDate.timeIntervalSinceNow
                    scheduleTokenRefresh(expiresIn: Int(timeUntilExpiry))
                    scheduleSessionTimeout(expiresIn: Int(timeUntilExpiry))

                } else {
                    await refreshTokenIfNeeded()
                }
            } else {

                await logout()
            }
        } catch {
            await logout()
        }
    }
    
    private func isTokenValid(_ token: String) async -> Bool {
        do {
            let _: UserModel = try await APILayer.shared.request(
                endpoint: "/auth/me",
                headers: ["Authorization": "Bearer \(token)"],
                responseType: UserModel.self
            )
            return true
        } catch {
            return false
        }
    }
    
    private func scheduleTokenRefresh(expiresIn: Int) {
        tokenRefreshTask?.cancel()
        
        // Refresh token 5 minutes before expiry
        let refreshTime = max(300, expiresIn - 300)
        
        tokenRefreshTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(refreshTime * 1_000_000_000))
            
            if !Task.isCancelled {
                print("⏰ Token refresh scheduled time reached")
                await refreshTokenIfNeeded()
            }
        }
    }
    
    private func scheduleSessionTimeout(expiresIn: Int) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(expiresIn * 1_000_000_000))
            if !Task.isCancelled {
                print("⏰ Session timeout reached")
                await logout()
            }
        }
    }
    
    private func refreshTokenIfNeeded(retryCount: Int = 0) async {
        do {
            guard let refreshToken = try await KeychainManager.shared.loadRefreshToken() else {
                await logout()
                return
            }
            
            let refreshRequest = RefreshTokenRequest(refreshToken: refreshToken)
            let requestData = try JSONEncoder().encode(refreshRequest)
            
            let response: LoginResponse = try await APILayer.shared.request(
                endpoint: "/auth/refresh",
                method: .POST,
                body: requestData,
                responseType: LoginResponse.self
            )
            
            // Update stored tokens
            try await KeychainManager.shared.saveToken(response.accessToken)
            try await KeychainManager.shared.saveRefreshToken(response.refreshToken)
            
            // Set token expiry to 30 minutes from now
            tokenExpiryDate = Date().addingTimeInterval(30 * 60)
            
            // Schedule next refresh and session timeout
            scheduleTokenRefresh(expiresIn: 30 * 60)
            scheduleSessionTimeout(expiresIn: 30 * 60)
            
        } catch {
            if retryCount < maxRetryAttempts {
                // Exponential backoff
                try? await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(retryCount)) * 1_000_000_000))
                await refreshTokenIfNeeded(retryCount: retryCount + 1)
            } else {
                await logout()
            }
        }
    }
    
    func getValidToken() async -> String? {
        if let expiryDate = tokenExpiryDate,
           expiryDate.timeIntervalSinceNow < 300 { // Less than 5 minutes left
            await refreshTokenIfNeeded()
        }
        
        return try? await KeychainManager.shared.loadToken()
    }
}


