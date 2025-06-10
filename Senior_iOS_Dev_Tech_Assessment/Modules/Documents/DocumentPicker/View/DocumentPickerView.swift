//
//  DocumentPickerView.swift
//  Senior_iOS_Dev_Tech_Assessment
//
//  Created by Yaroslav on 07.06.2025.
//
import SwiftUI

struct DocumentPickerView: UIViewControllerRepresentable {
    @Binding var selectedDocument: DocumentModel?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

