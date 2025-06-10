//
//  DocumentRowView.swift
//  Senior_iOS_Dev_Tech_Assessment
//
//  Created by Yaroslav on 10.06.2025.
//
import SwiftUI

struct DocumentRowView: View {
    let document: DocumentModel

    var body: some View {
        HStack {
            if let thumbnailData = document.thumbnail, let thumbnail = UIImage(data: thumbnailData) {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 65)
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "doc.fill")
                            .foregroundColor(.gray)
                    )
                    .frame(width: 50, height: 65)
                    .cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(document.name)
                    .font(.headline)
                    .lineLimit(2)

                Text(document.dateCreated, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(ByteCountFormatter.string(
                    fromByteCount: Int64(document.data.count),
                    countStyle: .file)
                )
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
