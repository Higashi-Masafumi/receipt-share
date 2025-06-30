//
//  UserRow.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/08.
//

import SwiftUI

struct UserRow: View {
    var user: User
    
    var body: some View {
        HStack {
            AsyncImage(url: user.photoURL) { image in
                image
                    .resizable()
                    .frame(width: 50, height: 50)
            } placeholder: {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            }
            Text(user.name)
                .font(.headline)
        }
    }
}

#Preview {
    return UserRow(user: mockuser)
}

