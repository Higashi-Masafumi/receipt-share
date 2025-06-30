//
//  UserView.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/08.
//

import SwiftUI

struct UserView: View {
    
    var user: User
    
    var body: some View {
        VStack() {
            CircleImage(imageURL: user.photoURL)
                .padding(.bottom, 20)
            
            Text(user.name)
                .font(.title)
                .foregroundColor(.primary)
            
            Text(user.email)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    UserView(
        user: mockuser
    )
}
