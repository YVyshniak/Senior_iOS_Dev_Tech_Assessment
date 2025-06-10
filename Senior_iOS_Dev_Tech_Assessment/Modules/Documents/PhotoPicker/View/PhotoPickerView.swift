//
//  PhotoPickerView.swift
//  Senior_iOS_Dev_Tech_Assessment
//
//  Created by Yaroslav on 07.06.2025.
//
import SwiftUI
import PhotosUI
import PDFKit

struct PhotoPickerView: UIViewControllerRepresentable {
    @Binding var selectedDocument: DocumentModel?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 0
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

