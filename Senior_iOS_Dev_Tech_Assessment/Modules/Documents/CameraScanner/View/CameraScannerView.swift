//
//  CameraScannerView.swift
//  Senior_iOS_Dev_Tech_Assessment
//
//  Created by Yaroslav on 08.06.2025.
//
import SwiftUI
import VisionKit
import PDFKit

struct CameraScannerView: UIViewControllerRepresentable {
    @Binding var scannedDocument: DocumentModel?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

