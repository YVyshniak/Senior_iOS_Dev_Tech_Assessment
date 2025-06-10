import SwiftUI
import WebKit
import SafariServices

struct TermsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else {
                    WebViewContainer(htmlContent: viewModel.cachedHTML)
                        .edgesIgnoringSafeArea(.bottom)
                }
            }
            .navigationTitle("Terms & Conditions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await viewModel.loadTerms()
        }
    }
}

// MARK: - WebView Container
struct WebViewContainer: UIViewRepresentable {
    let htmlContent: String
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        
        webView.allowsLinkPreview = false
        webView.allowsBackForwardNavigationGestures = false
        
        let darkModeScript = """
            document.body.style.color = '#FFFFFF';
            document.body.style.backgroundColor = '#000000';
            document.querySelectorAll('p, h1, h2, h3, h4, h5, h6, span, div').forEach(element => {
                element.style.color = '#FFFFFF';
            });
        """
        
        let userScript = WKUserScript(
            source: darkModeScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        
        webView.configuration.userContentController.addUserScript(userScript)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewContainer
        
        init(_ parent: WebViewContainer) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, shouldStartLoadWith request: URLRequest, navigationType: WKNavigationType) -> Bool {
            // Prevent navigation to external links
            return false
        }
    }
}
