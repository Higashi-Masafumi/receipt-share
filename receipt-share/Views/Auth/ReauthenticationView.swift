//
//  ReauthenticationView.swift
//  receipt-share
//
//  Created by AI Assistant on 2025/01/08.
//

import SwiftUI
import GoogleSignInSwift

struct ReauthenticationView: View {
    @Environment(ProfileViewModel.self) private var profileViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var email = ""
    @State private var password = ""
    @State private var showingErrorAlert = false
    @State private var userProviders: [String] = []
    
    let onSuccess: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("アカウント削除の確認")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("セキュリティのため、もう一度認証してください")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 16) {
                    // プロバイダー自動判定で適切な認証方法のみ表示
                    
                    // メール・パスワード認証（passwordプロバイダーの場合）
                    if userProviders.contains("password") {
                        TextField("メールアドレス", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        SecureField("パスワード", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: {
                            Task {
                                if await profileViewModel.reauthenticate(email: email, password: password) {
                                    onSuccess()
                                    dismiss()
                                } else {
                                    showingErrorAlert = true
                                }
                            }
                        }) {
                            HStack {
                                if profileViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "envelope")
                                    Text("メールで再認証")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .disabled(profileViewModel.isLoading || email.isEmpty || password.isEmpty)
                    }
                    
                    // Google再認証（google.comプロバイダーの場合）
                    if userProviders.contains("google.com") {
                        GoogleSignInButton(
                            scheme: colorScheme == .dark ? .dark : .light,
                            style: .wide,
                            action: {
                                Task {
                                    if await profileViewModel.reauthenticateWithGoogle() {
                                        onSuccess()
                                        dismiss()
                                    } else {
                                        showingErrorAlert = true
                                    }
                                }
                            }
                        )
                        .frame(height: 50)
                        .cornerRadius(8)
                        .disabled(profileViewModel.isLoading)
                        .opacity(profileViewModel.isLoading ? 0.6 : 1.0)
                    }
                    
                    // Apple再認証（apple.comプロバイダーの場合）
                    if userProviders.contains("apple.com") {
                        Button(action: {
                            Task {
                                // Apple Sign Inの場合は削除専用フローを実行
                                do {
                                    try await profileViewModel.deleteAccountWithApple()
                                    dismiss()
                                } catch {
                                    showingErrorAlert = true
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "apple.logo")
                                    .foregroundColor(.white)
                                Text("Appleで認証して削除")
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(8)
                        }
                        .disabled(profileViewModel.isLoading)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("再認証")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
            .alert("認証エラー", isPresented: $showingErrorAlert) {
                Button("OK") { }
            } message: {
                Text(profileViewModel.errorMessage.isEmpty ? "再認証に失敗しました" : profileViewModel.errorMessage)
            }
        }
        .onAppear {
            if let currentUser = profileViewModel.userProfile {
                email = currentUser.email
            }
            // プロバイダー情報を取得
            userProviders = profileViewModel.getCurrentProviders()
        }
    }
}

#Preview {
    ReauthenticationView(onSuccess: {})
        .environment(ProfileViewModel(
            authRepository: FirebaseAuthRepository(),
            userRepository: FirebaseUserRepository(),
            storageRepository: FirebaseStorageRepository(),
            currentUser: AuthUser(id: "test", email: "test@example.com")
        ))
} 