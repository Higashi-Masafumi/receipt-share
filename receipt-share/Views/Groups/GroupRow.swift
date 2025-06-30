//
//  GroupRow.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/09.
//

import SwiftUI

struct GroupRow: View {
    
    var group: GroupWithoutMembers
    
    var body: some View {
        HStack {
            AsyncImage(url: group.photoURL) { image in
                image
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } placeholder: {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            }
            Text(group.name)
                .font(.headline)
        }
    }
}
