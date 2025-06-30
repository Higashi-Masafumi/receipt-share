//
//  UserList.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/08.
//

import SwiftUI

struct UserList: View {
    
    var users: [User]
    
    var body: some View {
        List {
            ForEach(users) { user in
                NavigationLink {
                    UserView(user: user)
                } label: {
                    UserRow(user: user)
                }
            }
        }
        .animation(.default, value: users)
        .navigationTitle("Users")
    }
}

#Preview {
    NavigationStack {
        UserList(users: [mockuser])
    }
}
