//
//  DocumentPickerCoordinator.swift
//  Senior_iOS_Dev_Tech_Assessment
//
//  Created by Yaroslav on 07.06.2025.
//
import SwiftUI

extension DocumentPickerView {
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPickerView
        
        init(_ parent: DocumentPickerView) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            Task {
                let document = await handleDocumentSelection(from: urls)
                await MainActor.run {
                    parent.selectedDocument = document
                    parent.dismiss()
                }
            }
        }
        
        func handleDocumentSelection(from urls: [URL]) async -> DocumentModel? {
            guard let url = urls.first else { return nil }
            
            return await Task.detached {
                do {
                    let data = try Data(contentsOf: url)
                    let documentsManager = await DocumentsManager()
                    let thumbnailData = await documentsManager.generateThumbnail(from: data)
                    
                    return DocumentModel(
                        name: url.lastPathComponent,
                        data: data,
                        thumbnail: thumbnailData
                    )
                } catch {
                    print("Failed to load document: \(error)")
                    return nil
                }
            }.value
        }
    }
}

