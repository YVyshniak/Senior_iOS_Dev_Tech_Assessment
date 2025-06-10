//
//  LoginRequest.swift
//  Senior_iOS_Dev_Tech_Assessment
//
//  Created by Yaroslav on 09.06.2025.
//
import Foundation

struct LoginRequest: Codable {
    let username: String
    let password: String
    var expiresInMins: Int = 30
}

struct LoginResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let id: Int
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let gender: String
    let image: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken
        case refreshToken
        case id
        case username
        case email
        case firstName
        case lastName
        case gender
        case image
    }
}

struct UploadResponse: Codable {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let discountPercentage: Double
    let rating: Double
    let stock: Int
    let brand: String
    let category: String
    let thumbnail: String
    let images: [String]
}

struct QueuedUpload: Codable {
    let fileURL: URL
    let metadata: [String: String]
    let timestamp: Date
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
    var expiresInMins: Int = 30
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError
    case unauthorized
    case serverError(Int)
    case noConnection
    case noInternetConnection
    case serverUnreachable
    case timeout
    case unknown
    
    var errorDescription: String? {
        switch self {
            case .invalidURL: return "Invalid URL"
            case .invalidResponse: return "Invalid response from server"
            case .noData: return "No data received"
            case .decodingError: return "Failed to decode response"
            case .unauthorized: return "Unauthorized access"
            case .serverError(let code): return "Server error: \(code)"
            case .noConnection: return "Unable to connect to server"
            case .noInternetConnection: return "No internet connection"
            case .serverUnreachable: return "Server is unreachable"
            case .timeout: return "Request timed out"
            case .unknown: return "An unknown error occurred"
        }
    }
}

struct EmptyResponse: Codable {}
