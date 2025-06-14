//
//  Senior_iOS_Dev_Tech_AssessmentApp.swift
//  Senior_iOS_Dev_Tech_Assessment
//
//  Created by Yaroslav on 05.06.2025.
//
import SwiftUI

@main
struct Senior_iOS_Dev_Tech_AssessmentApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var delegate
    
    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
                .ignoresSafeArea()
        }
    }
}

