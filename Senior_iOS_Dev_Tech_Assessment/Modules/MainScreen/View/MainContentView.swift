//
//  MainContentView.swift
//  Senior_iOS_Dev_Tech_Assessment
//
//  Created by Yaroslav on 06.06.2025.
//
import SwiftUI

struct MainContentView: View {
    @StateObject private var documentsManager = DocumentsManager()
    @StateObject private var networkMonitor = NetworkManager.shared
    @ObservedObject var authManager: APIAuth
    @State private var showingDocumentPicker = false
    @State private var showingCameraScanner = false
    @State private var showingPhotoPicker = false
    @State private var selectedDocument: DocumentModel?
    @State private var documentToView: DocumentModel?
    @State private var showingAddOptions = false
    @State private var showingLoginView = false
    @State private var showingTermsView = false
    
    var body: some View {
        VStack(spacing: 0) {
            if !networkMonitor.isConnected {
                OfflineBannerView()
            }
            
            NavigationView {
                VStack {
                    if documentsManager.documents.isEmpty {
                        emptyStateView
                    } else {
                        documentListView
                    }
                }
                .navigationTitle("Documents Vault")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if let user = authManager.currentUser {
                            Menu {
                                Button(action: {
                                    Task {
                                        await authManager.logout()
                                    }
                                }) {
                                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                                }
                            } label: {
                                HStack {
                                    AsyncImage(url: URL(string: user.image)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Circle()
                                            .fill(Color.gray.opacity(0.3))
                                            .overlay(
                                                Image(systemName: "person.fill")
                                                    .foregroundColor(.gray)
                                            )
                                    }
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                                    
                                    Text(user.firstName)
                                        .font(.subheadline)
                                }
                            }
                        } else {
                            Button(action: { showingLoginView = true }) {
                                HStack {
                                    Image(systemName: "person.circle")
                                    Text("Sign In")
                                }
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button(action: { showingTermsView = true }) {
                                Image(systemName: "doc.text")
                            }
                            
                            Button(action: { showingAddOptions = true }) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingAddOptions) {
                    addOptionsView
                }
                .sheet(isPresented: $showingDocumentPicker) {
                    DocumentPickerView(selectedDocument: $selectedDocument)
                }
                .sheet(isPresented: $showingCameraScanner) {
                    CameraScannerView(scannedDocument: $selectedDocument)
                }
                .sheet(isPresented: $showingPhotoPicker) {
                    PhotoPickerView(selectedDocument: $selectedDocument)
                }
                .sheet(isPresented: $showingLoginView) {
                    LoginView(viewModel: LoginView.ViewModel())
                }
                .sheet(isPresented: $showingTermsView) {
                    TermsView()
                }
                .sheet(item: $documentToView) { document in
                    DocumentDetailView(document: document)
                }
                .onChange(of: selectedDocument) { document in
                    if let document = document {
                        Task {
                            await documentsManager.addDocument(document)
                        }
                        selectedDocument = nil
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Documents")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add your first document using the + button")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var documentListView: some View {
        List {
            ForEach(documentsManager.getDocuments()) { document in
                DocumentRowView(document: document)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        documentToView = document
                    }
            }
            .onDelete { offsets in
                Task {
                    await documentsManager.deleteDocument(at: offsets)
                }
            }
        }
    }
    
    private var addOptionsView: some View {
        NavigationView {
            List {
                Button(action: {
                    showingAddOptions = false
                    showingDocumentPicker = true
                }) {
                    Label("Import from Files", systemImage: "folder")
                }
                
                Button(action: {
                    showingAddOptions = false
                    showingCameraScanner = true
                }) {
                    Label("Scan Document", systemImage: "camera")
                }
                
                Button(action: {
                    showingAddOptions = false
                    showingPhotoPicker = true
                }) {
                    Label("Convert Photos to PDF", systemImage: "photo")
                }
            }
            .navigationTitle("Add Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showingAddOptions = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    MainContentView(authManager: APIAuth.shared)
}



