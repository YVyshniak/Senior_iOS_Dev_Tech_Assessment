//
//  DocumentModel.swift
//  Senior_iOS_Dev_Tech_Assessment
//
//  Created by Yaroslav on 06.06.2025.
//
import Foundation

struct DocumentModel: Codable, Identifiable, Equatable {
    var id = UUID()
    let name: String
    let data: Data
    let dateCreated: Date
    let thumbnail: Data?
    
    init(name: String,
         data: Data,
         thumbnail: Data? = nil) {
        self.name = name
        self.data = data
        self.dateCreated = Date()
        self.thumbnail = thumbnail
    }
    
    static func == (lhs: DocumentModel, rhs: DocumentModel) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.data == rhs.data &&
               lhs.dateCreated == rhs.dateCreated &&
               lhs.thumbnail == rhs.thumbnail
    }
}
