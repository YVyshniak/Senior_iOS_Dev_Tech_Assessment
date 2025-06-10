//
//  APILayer.swift
//  Senior_iOS_Dev_Tech_Assessment
//
//  Created by Yaroslav on 09.06.2025.
//
import SwiftUI
import Network

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

actor APILayer {
    static let shared = APILayer()
    
    private let baseURL = "https://dummyjson.com"
    private let session: URLSession
    private let maxRetryAttempts = 3
    private let retryDelay: TimeInterval = 1.0
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request<T: Decodable>(endpoint: String, method: HTTPMethod = .GET, body: Data? = nil) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var retryCount = 0
        
        while retryCount < maxRetryAttempts {
            do {
                let (data, response) = try await session.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    do {
                        return try JSONDecoder().decode(T.self, from: data)
                    } catch {
                        throw APIError.decodingError
                    }
                case 401:
                    throw APIError.unauthorized
                case 400...499:
                    throw APIError.serverError(httpResponse.statusCode)
                case 500...599:
                    retryCount += 1
                    if retryCount < maxRetryAttempts {
                        try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(retryCount)) * 1_000_000_000))
                        continue
                    }
                    throw APIError.serverError(httpResponse.statusCode)
                default:
                    throw APIError.unknown
                }
            } catch let error as URLError {
                switch error.code {
                case .notConnectedToInternet:
                    throw APIError.noInternetConnection
                case .cannotConnectToHost:
                    throw APIError.serverUnreachable
                case .timedOut:
                    throw APIError.timeout
                default:
                    retryCount += 1
                    if retryCount < maxRetryAttempts {
                        try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(retryCount)) * 1_000_000_000))
                        continue
                    }
                    throw APIError.unknown
                }
            }
        }
        
        throw APIError.unknown
    }
    
    private func performRequestWithRetry<T: Codable>(
        request: URLRequest,
        responseType: T.Type,
        attempt: Int = 1
    ) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoded = try JSONDecoder().decode(responseType, from: data)
                    return decoded
                } catch {
                    throw APIError.decodingError
                }
            case 401:
                throw APIError.unauthorized
            case 400...499:
                throw APIError.serverError(httpResponse.statusCode)
            case 500...599:
                if attempt < maxRetryAttempts {
                    try await Task.sleep(nanoseconds: UInt64(retryDelay * Double(attempt) * 1_000_000_000))
                    return try await performRequestWithRetry(request: request, responseType: responseType, attempt: attempt + 1)
                }
                throw APIError.serverError(httpResponse.statusCode)
            default:
                throw APIError.unknown
            }
        } catch let error as APIError {
            throw error
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet:
                throw APIError.noInternetConnection
            case .cannotConnectToHost:
                throw APIError.serverUnreachable
            case .timedOut:
                throw APIError.timeout
            default:
                throw APIError.noConnection
            }
        } catch {
            if attempt < maxRetryAttempts {
                try await Task.sleep(nanoseconds: UInt64(retryDelay * Double(attempt) * 1_000_000_000))
                return try await performRequestWithRetry(request: request, responseType: responseType, attempt: attempt + 1)
            }
            throw APIError.unknown
        }
    }
    
    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Data? = nil,
        headers: [String: String] = [:],
        responseType: T.Type
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return try await performRequestWithRetry(request: request, responseType: responseType)
    }
}
