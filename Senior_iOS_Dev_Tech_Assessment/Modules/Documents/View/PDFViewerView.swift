//
//  PDFViewerView.swift
//  Senior_iOS_Dev_Tech_Assessment
//
//  Created by Yaroslav on 10.06.2025.
//
import SwiftUI
import PDFKit

struct PDFViewerView: UIViewRepresentable {
    let document: PDFDocument
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}
