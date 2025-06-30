//
//  ResetPassword.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/26.
//

import SwiftUI

struct ResetPasswordView: View {
    @Environment(AuthViewModel.self) var authViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var email: String = ""
    @FocusState private var isEmailFocused: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // アイコンとタイトル
                    VStack(spacing: 12) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.blue)
                        
                        Text("パスワードリセット")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("登録済みのメールアドレスを入力してください。\nパスワードリセット用のリンクをお送りします。")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // 成功メッセージ
                    if authViewModel.passwordResetEmailSent {
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.green)
                            
                            VStack(spacing: 8) {
                                Text("メール送信完了")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text("メール内のリンクをタップして、ブラウザでパスワードを変更してください。")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Button("ログイン画面に戻る") {
                                authViewModel.resetPasswordResetState()
                                dismiss()
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                        }
                        .padding(20)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                    } else {
                        // 入力フォーム
                        VStack(spacing: 16) {
                            // メールアドレス入力
                            VStack(alignment: .leading, spacing: 8) {
                                Text("メールアドレス")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                TextField("メールアドレスを入力", text: $email)
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .focused($isEmailFocused)
                                    .submitLabel(.send)
                                    .onSubmit {
                                        if isValidEmail(email) {
                                            sendResetEmail()
                                        }
                                    }
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            // 送信ボタン
                            Button(action: sendResetEmail) {
                                Text("リセットメールを送信")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .disabled(!isValidEmail(email) || authViewModel.isLoading)
                            
                            // 注意事項
                            VStack(alignment: .leading, spacing: 8) {
                                Text("ご注意")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("• メール/パスワードで登録されたアカウントのみ対象です")
                                    Text("• Apple ID、Googleアカウントでログインの方は、各サービスでパスワード管理をお願いします")
                                    Text("• メールが届かない場合は迷惑メールフォルダもご確認ください")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                            .padding(12)
                            .background(Color(UIColor.tertiarySystemBackground))
                            .cornerRadius(8)
                        }
                        .padding(20)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("パスワードリセット")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        authViewModel.resetPasswordResetState()
                        dismiss()
                    }
                }
            }
            .overlay {
                // ローディングオーバーレイ
                if authViewModel.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("送信中...")
                            .font(.subheadline)
                    }
                    .padding(20)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(12)
                }
            }
        }
        .alert("エラー", isPresented: .constant(authViewModel.errorMessage != nil)) {
            Button("OK") {
                authViewModel.errorMessage = nil
            }
        } message: {
            Text(authViewModel.errorMessage ?? "")
        }
        .onAppear {
            isEmailFocused = true
        }
    }
    
    private func sendResetEmail() {
        Task {
            await authViewModel.sendPasswordResetEmail(email: email)
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
}

#Preview {
    ResetPasswordView()
        .environment(AuthViewModel(authRepository: FirebaseAuthRepository()))
}

