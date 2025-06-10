//
//  TermsViewModel.swift
//  Senior_iOS_Dev_Tech_Assessment
//
//  Created by Yaroslav on 10.06.2025.
//
import SwiftUI

extension TermsView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published var isLoading = true
        @Published var cachedHTML = ""
        
        private let termsURL = "https://example.com/terms.html"
        private let cacheKey = "terms_html_cache"
        
        func loadTerms() async {
            isLoading = true
            
            // Try to load from cache first
            if let cached = UserDefaults.standard.string(forKey: cacheKey) {
                cachedHTML = cached
                isLoading = false
                return
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: URL(string: termsURL)!)
                if let html = String(data: data, encoding: .utf8) {
                    // Cache the HTML
                    UserDefaults.standard.set(html, forKey: cacheKey)
                    cachedHTML = html
                }
            } catch {
                // Network fail
                cachedHTML = """
                    <html>
                        <body style="color: white; background-color: black; padding: 20px;">
                            <h1>Unable to load Terms & Conditions</h1>
                            <p>Please check your internet connection and try again.</p>
                        </body>
                    </html>
                """
            }
            
            isLoading = false
        }
    }
}
