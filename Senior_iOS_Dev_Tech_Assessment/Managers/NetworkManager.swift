//
//  NetworkManager.swift
//  Senior_iOS_Dev_Tech_Assessment
//
//  Created by Yaroslav on 09.06.2025.
//
import SwiftUI
import Network

final class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    @MainActor @Published var isConnected = true
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}
