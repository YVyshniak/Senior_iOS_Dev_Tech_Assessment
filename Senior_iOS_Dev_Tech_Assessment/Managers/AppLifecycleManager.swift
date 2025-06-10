//
//  AppLifecycleManager.swift
//  Senior_iOS_Dev_Tech_Assessment
//
//  Created by Yaroslav on 06.06.2025.
//
import SwiftUI

class AppLifecycleManager: ObservableObject {
    @Published var isInBackground = false
    
    init() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                self.isInBackground = true
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                self.isInBackground = false
            }
        }
    }
}
