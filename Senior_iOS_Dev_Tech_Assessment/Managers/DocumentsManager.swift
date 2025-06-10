//
//  DocumentManager.swift
//  Senior_iOS_Dev_Tech_Assessment
//
//  Created by Yaroslav on 06.06.2025.
//
import SwiftUI
import PDFKit

@MainActor
final class DocumentsManager: ObservableObject {
    
    @Published var documents: [DocumentModel] = []
    private let documentsKey = "documentsKey"
    
    init() {
        Task {
            await loadDocuments()
        }
    }
    
    func addDocument(_ document: DocumentModel) async {
        documents.append(document)
        await saveDocuments()
    }
    
    func deleteDocument(at offsets: IndexSet) async {
        documents.remove(atOffsets: offsets)
        await saveDocuments()
    }
    
    func getDocuments() -> [DocumentModel] {
        return documents
    }
    
    private func saveDocuments() async {
        do {
            let data = try JSONEncoder().encode(documents)
            UserDefaults.standard.set(data, forKey: documentsKey)
        } catch {
            print("Failed to save documents: \(error)")
        }
    }
    
    private func loadDocuments() async {
        guard let data = UserDefaults.standard.data(forKey: documentsKey) else { return }
        do {
            documents = try JSONDecoder().decode([DocumentModel].self, from: data)
        } catch {
            print("Failed to load documents: \(error)")
        }
    }
    
    nonisolated func generateThumbnail(from pdfData: Data) async -> Data? {
        return await Task.detached {
            guard let document = PDFDocument(data: pdfData),
                  let page = document.page(at: 0) else { return nil }
            
            let pageRect = page.bounds(for: .mediaBox)
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 130))
            
            let image = renderer.image { context in
                UIColor.white.set()
                context.fill(CGRect(origin: .zero, size: CGSize(width: 100, height: 130)))
                
                context.cgContext.translateBy(x: 0, y: 130)
                context.cgContext.scaleBy(x: 100/pageRect.width, y: -130/pageRect.height)
                page.draw(with: .mediaBox, to: context.cgContext)
            }
            
            return image.jpegData(compressionQuality: 0.8)
        }.value
    }
}
