//
//  OfflineBannerView.swift
//  Senior_iOS_Dev_Tech_Assessment
//
//  Created by Yaroslav on 09.06.2025.
//
import SwiftUI

struct OfflineBannerView: View {
    var body: some View {
        HStack {
            Image(systemName: "wifi.slash")
                .foregroundColor(.white)
            
            Text("You're offline")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.red)
    }
}
