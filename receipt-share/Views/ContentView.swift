//
//  ContentView.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/08.
//

import SwiftUI
import FirebaseCore

struct ContentView: View {
    var user: AuthUser
    
    var body: some View {
        TabView {
            GroupList()
                .environment(GroupListViewModel(groupRepository: FirebaseGroupRepository(), user: user))
                .tabItem {
                    Label("Groups", systemImage: "person.3.fill")
                }
                .accessibilityIdentifier("GroupsTab")
            NewReceiptView()
                .environment(NewReceiptViewModel(currentUser: user,
                                                 groupRepository: FirebaseGroupRepository(),
                                                 storageRepository: FirebaseStorageRepository(), receiptRepository: FirebaseReceiptRepository()))
                .tabItem {
                    Label("Scan", systemImage: "camera.fill")
                }
                .accessibilityIdentifier("ScanTab")
            ProfileView()
                .environment(ProfileViewModel(authRepository: FirebaseAuthRepository(), userRepository: FirebaseUserRepository(), storageRepository: FirebaseStorageRepository(), currentUser: user))
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .accessibilityIdentifier("ProfileTab")
        }
    }
}
