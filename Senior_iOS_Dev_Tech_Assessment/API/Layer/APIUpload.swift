//
//  APIUpload.swift
//  Senior_iOS_Dev_Tech_Assessment
//
//  Created by Yaroslav on 10.06.2025.
//
import SwiftUI
import Network
import Foundation

@MainActor
final class APIUpload: ObservableObject {
    static let shared = APIUpload()
    
    @Published private(set) var isUploading = false
    @Published private(set) var queuedUploads: [QueuedUpload] = []
    
    private let queue = DispatchQueue(label: "com.app.fileupload", qos: .background)
    private var syncTimer: Timer?
    private var uploadTasks: [URLSessionUploadTask] = []
    
    private let api: APILayer
    private let maxRetryAttempts = 3
    private let networkMonitor = NWPathMonitor()
    private var isOnline = false
    
    init(api: APILayer = APILayer()) {
        self.api = api
        setupNetworkMonitoring()
        startSyncTimer()
        loadQueuedUploads()
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            Task { [weak self] in
                await self?.handleNetworkChange(isOnline: path.status == .satisfied)
            }
        }
        networkMonitor.start(queue: DispatchQueue.global())
    }
    
    private func handleNetworkChange(isOnline: Bool) {
        self.isOnline = isOnline
        if isOnline {
            Task {
                await syncQueuedUploads()
            }
        }
    }
    
    private func startSyncTimer() {
        syncTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            Task { [weak self] in
                await self?.checkAndSyncUploads()
            }
        }
    }
    
    private func checkAndSyncUploads() async {
        if isOnline {
            await syncQueuedUploads()
        }
    }
    
    private func syncQueuedUploads() async {
        let queuedUploads = await loadQueuedUploads()
        
        for upload in queuedUploads {
            do {
                let response = try await uploadFile(upload.fileURL, metadata: upload.metadata)
                await removeQueuedUpload(upload)
            } catch {
            }
        }
    }
    
    private func saveQueuedUploads() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(queuedUploads) {
            UserDefaults.standard.set(data, forKey: "queued_uploads")
        }
    }
    
    private func loadQueuedUploads() {
        if let data = UserDefaults.standard.data(forKey: "queued_uploads"),
           let uploads = try? JSONDecoder().decode([QueuedUpload].self, from: data) {
            queuedUploads = uploads
        }
    }
    
    func uploadFile(_ fileURL: URL, metadata: [String: String]) async throws -> UploadResponse {
        if !isOnline {
            await queueUpload(fileURL: fileURL, metadata: metadata)
            throw APIError.noInternetConnection
        }
        
        let fileData = try Data(contentsOf: fileURL)
        
        // Create multipart form data
        let boundary = UUID().uuidString
        var body = Data()
        
        // metadata
        for (key, value) in metadata {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Add file data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        
        var request = URLRequest(url: URL(string: "https://dummyjson.com/products/add")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        var retryCount = 0
        
        while retryCount < maxRetryAttempts {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    do {
                        return try JSONDecoder().decode(UploadResponse.self, from: data)
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
                    await queueUpload(fileURL: fileURL, metadata: metadata)
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
    
    // MARK: - Queue Management
    
   
    
    private func queueUpload(fileURL: URL, metadata: [String: String]) async {
        let upload = QueuedUpload(fileURL: fileURL, metadata: metadata, timestamp: Date())
        var uploads = await loadQueuedUploads()
        uploads.append(upload)
        await saveQueuedUploads(uploads)
    }
    
    private func removeQueuedUpload(_ upload: QueuedUpload) async {
        var uploads = await loadQueuedUploads()
        uploads.removeAll { $0.fileURL == upload.fileURL }
        await saveQueuedUploads(uploads)
    }
    
    private func loadQueuedUploads() async -> [QueuedUpload] {
        guard let data = UserDefaults.standard.data(forKey: "queuedUploads") else {
            return []
        }
        return (try? JSONDecoder().decode([QueuedUpload].self, from: data)) ?? []
    }
    
    private func saveQueuedUploads(_ uploads: [QueuedUpload]) async {
        guard let data = try? JSONEncoder().encode(uploads) else { return }
        UserDefaults.standard.set(data, forKey: "queuedUploads")
    }
}


