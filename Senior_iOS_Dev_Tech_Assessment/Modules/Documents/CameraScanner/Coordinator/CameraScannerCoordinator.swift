//
//  CameraScannerCoordinator.swift
//  Senior_iOS_Dev_Tech_Assessment
//
//  Created by Yaroslav on 10.06.2025.
//
import SwiftUI
import VisionKit
import PDFKit

extension CameraScannerView {
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: CameraScannerView
        
        init(_ parent: CameraScannerView) {
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            Task {
                let document = await processScan(scan)
                await MainActor.run {
                    parent.scannedDocument = document
                    parent.dismiss()
                }
            }
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.dismiss()
        }
        
        
        func processScan(_ scan: VNDocumentCameraScan) async -> DocumentModel? {
            return await Task.detached {
                let pdfDocument = PDFDocument()
                
                for i in 0..<scan.pageCount {
                    let image = scan.imageOfPage(at: i)
                    if let pdfPage = PDFPage(image: image) {
                        pdfDocument.insert(pdfPage, at: i)
                    }
                }
                
                guard let pdfData = pdfDocument.dataRepresentation() else { return nil }
                
                let documentManager = await DocumentsManager()
                let thumbnailData = await documentManager.generateThumbnail(from: pdfData)
                
                return DocumentModel(
                    name: "Scanned Document \(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short))",
                    data: pdfData,
                    thumbnail: thumbnailData
                )
            }.value
        }
    }
}

