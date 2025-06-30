//
//  ProfileView.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/25.
//

import SwiftUI

struct ProfileView: View {
    @Environment(ProfileViewModel.self) private var profileViewModel: ProfileViewModel
    @State private var isEditing = false
    @State private var draftUser = User(id: "", name: "", photoURL: URL(string: "https://example.com")!, email: "")
    @State private var showingDeleteConfirmation = false
    @State private var showingReauthentication = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // プロフィール表示部分
                if profileViewModel.isLoading {
                    ProgressView("プロフィールを読み込み中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let user = profileViewModel.userProfile {
                    // UserViewコンポーネントを使用
                    UserView(user: user)
                        .padding(.top, 30)
                } else {
                    Text("プロフィールが見つかりません")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                Spacer()
                
                // ボタン部分（常に表示）
                VStack(spacing: 16) {
                    // サインアウトボタン
                    Button(action: {
                        Task {
                            await profileViewModel.signOut()
                        }
                    }) {
                        Label("サインアウト", systemImage: "rectangle.portrait.and.arrow.right")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(profileViewModel.isLoading)
                    
                    // アカウント削除ボタン
                    Button(action: {
                        showingDeleteConfirmation = true
                    }) {
                        Label("アカウント削除", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(profileViewModel.isLoading)
                }
                .padding(.horizontal)
                .padding(.bottom, 50)
            }
            .navigationTitle("プロフィール")
            .onAppear {
                profileViewModel.loadUserProfile()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isEditing.toggle()
                    }) {
                        Text(isEditing ? "完了" : "編集")
                    }
                    .disabled(profileViewModel.userProfile == nil)
                }
            }
            .alert("エラー", isPresented: .constant(!profileViewModel.errorMessage.isEmpty)) {
                Button("OK") {
                    profileViewModel.clearError()
                }
            } message: {
                Text(profileViewModel.errorMessage)
            }
            .confirmationDialog("アカウントを削除", isPresented: $showingDeleteConfirmation) {
                Button("削除", role: .destructive) {
                    showingReauthentication = true
                }
                Button("キャンセル", role: .cancel) { }
            } message: {
                Text("この操作は取り消せません。すべてのデータが完全に削除されます。")
            }
            .sheet(isPresented: $isEditing) {
                ProfileEditSheet(user: $draftUser, isPresented: $isEditing)
                    .onAppear {
                        draftUser = profileViewModel.userProfile ?? draftUser
                    }
            }
            .sheet(isPresented: $showingReauthentication) {
                ReauthenticationView(onSuccess: {
                    Task {
                        await profileViewModel.deleteAccount()
                    }
                })
                .environment(profileViewModel)
            }
        }
    }
}

#Preview {
    ProfileView()
        .environment(ProfileViewModel(
            authRepository: FirebaseAuthRepository(),
            userRepository: FirebaseUserRepository(),
            storageRepository: FirebaseStorageRepository(),
            currentUser: AuthUser(id: "test", email: "test@example.com")
        ))
}

