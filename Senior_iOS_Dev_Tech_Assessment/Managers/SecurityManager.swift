//
//  SecurityManager.swift
//  Senior_iOS_Dev_Tech_Assessment
//
//  Created by Yaroslav on 06.06.2025.
//
import SwiftUI
import LocalAuthentication

actor SecurityManager: ObservableObject {
    
    @MainActor @Published var isUnlocked = false
    @MainActor @Published var isJailbroken = false
    
    init() {
        Task {
            await checkJailbreak()
        }
    }
    
// MARK: - Auth
    func authenticateUser() async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return await authenticateWithPasscode()
        }
        
        do {
            let result = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Access your secure documents vault"
            )
            await MainActor.run {
                self.isUnlocked = result
            }
            return result
        } catch {
            return await authenticateWithPasscode()
        }
    }
    
    private func authenticateWithPasscode() async -> Bool {
        let context = LAContext()
        do {
            let result = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: "Access your secure documents vault"
            )
            await MainActor.run {
                self.isUnlocked = result
            }
            return result
        } catch {
            return false
        }
    }
    
    
    //MARK: - Jailbreak checker
    private func checkJailbreak() async {
#if targetEnvironment(simulator)
        return
#else
        let isJailbroken = await Task.detached { () -> Bool in
            let paths = [
                "/Applications/Cydia.app",
                "/Library/MobileSubstrate/MobileSubstrate.dylib",
                "/bin/bash",
                "/usr/sbin/sshd",
                "/etc/apt",
                "/private/var/lib/apt/",
                "/Applications/blackra1n.app",
                "/Applications/FakeCarrier.app",
                "/Applications/Icy.app",
                "/Applications/IntelliScreen.app",
                "/Applications/MxTube.app",
                "/Applications/RockApp.app",
                "/Applications/SBSettings.app",
                "/Applications/WinterBoard.app"
            ]
            
            for path in paths {
                if FileManager.default.fileExists(atPath: path) {
                    return true
                }
            }
            
            let testString = "test"
            do {
                try testString.write(toFile: "/private/test.txt", atomically: true, encoding: .utf8)
                try FileManager.default.removeItem(atPath: "/private/test.txt")
                return true
            } catch {
                return false
            }
        }.value
        
        await MainActor.run {
            self.isJailbroken = isJailbroken
        }
#endif
    }
}


