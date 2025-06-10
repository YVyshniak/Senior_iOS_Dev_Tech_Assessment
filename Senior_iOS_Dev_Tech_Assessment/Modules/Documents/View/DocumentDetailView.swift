//
//  DocumentDetailView.swift
//  Senior_iOS_Dev_Tech_Assessment
//
//  Created by Yaroslav on 08.06.2025.
//
import SwiftUI
import PDFKit

struct DocumentDetailView: View {
    let document: DocumentModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Group {
                if let pdfDocument = PDFDocument(data: document.data) {
                    PDFViewerView(document: pdfDocument)
                } else {
                    Text("Unable to load document")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(document.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}



