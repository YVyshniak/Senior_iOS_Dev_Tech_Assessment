//
//  PhotoPickerCoordinator.swift
//  Senior_iOS_Dev_Tech_Assessment
//
//  Created by Yaroslav on 10.06.2025.
//
import SwiftUI
import PhotosUI
import PDFKit

extension PhotoPickerView {
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickerView
        
        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            print("Picker returned \(results.count) result(s)")
            Task {
                let document = await processPhotos(results)
                await MainActor.run {
                    parent.selectedDocument = document
                    parent.dismiss()
                }
            }
        }
        
        func processPhotos(_ results: [PHPickerResult]) async -> DocumentModel? {
            guard !results.isEmpty else { return nil }

            return await Task.detached {
                let pdfDocument = PDFDocument()
                var images: [(Int, UIImage)] = []

                await withTaskGroup(of: (Int, UIImage?).self) { group in
                    for (index, result) in results.enumerated() {
                        group.addTask {
                            return await withUnsafeContinuation { continuation in
                                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                                    if let error = error {
 
                                    }
                                    continuation.resume(returning: (index, image as? UIImage))
                                }
                            }
                        }
                    }

                    for await (index, image) in group {
                        if let image = image {
                            images.append((index, image))
                        } else {
                        }
                    }
                }

                if images.isEmpty {
                    return nil
                }

                images.sort { $0.0 < $1.0 }

                for (_, image) in images {
                    if let pdfPage = PDFPage(image: image) {
                        pdfDocument.insert(pdfPage, at: pdfDocument.pageCount)
                    }
                }

                guard let pdfData = pdfDocument.dataRepresentation() else {
                    return nil
                }

                let documentManager = await DocumentsManager()
                let thumbnailData = await documentManager.generateThumbnail(from: pdfData)

                return DocumentModel(
                    name: "Photos to PDF \(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short))",
                    data: pdfData,
                    thumbnail: thumbnailData
                )
            }.value
        }
    }
}
