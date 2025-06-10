//
//  KeychainManager.swift
//  Senior_iOS_Dev_Tech_Assessment
//
//  Created by Yaroslav on 09.06.2025.
//
import Security
import Foundation

//Storing as plain text is NOT secure without additional encoding/decoding overhead
actor KeychainManager {
    
    static let shared = KeychainManager()
    
    private let service = "service"
    private let tokenKey = "authToken"
    private let refreshTokenKey = "refreshToken"
    private let userKey = "currentUser"
    
    
    func save<T: Codable>(_ item: T, key: String) throws {
        let data = try JSONEncoder().encode(item)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw APIError.unknown
        }
    }
    
    func load<T: Codable>(_ type: T.Type, key: String) throws -> T? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data else {
            return nil
        }
        
        return try JSONDecoder().decode(type, from: data)
    }
    
    func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    
    func saveToken(_ token: String) throws {
        try save(token, key: tokenKey)
    }
    
    func loadToken() throws -> String? {
        return try load(String.self, key: tokenKey)
    }
    
    func saveRefreshToken(_ refreshToken: String) throws {
        try save(refreshToken, key: refreshTokenKey)
    }
    
    func loadRefreshToken() throws -> String? {
        return try load(String.self, key: refreshTokenKey)
    }
    
    func saveUser(_ user: UserModel) throws {
        try save(user, key: userKey)
    }
    
    func loadUser() throws -> UserModel? {
        return try load(UserModel.self, key: userKey)
    }
    
    func clearAll() {
        delete(key: tokenKey)
        delete(key: refreshTokenKey)
        delete(key: userKey)
    }
}
