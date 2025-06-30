//
//  SignIn.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/12.
//
import SwiftUI
import GoogleSignInSwift

struct SignInView: View {
    @Environment(AuthViewModel.self) var authViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSignUp = false  // サインアップモード切替用
    @State private var showResetPassword = false  // パスワードリセット画面表示用
    @FocusState private var focusField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        ZStack {
            // 背景グラデーション - ダークモードに応じて色を調整
            LinearGradient(gradient:
                            Gradient(colors: [
                                colorScheme == .dark ? Color.blue.opacity(0.2) : Color.blue.opacity(0.3),
                                colorScheme == .dark ? Color.purple.opacity(0.1) : Color.purple.opacity(0.2)
                            ]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // ロゴまたはアプリ名
                VStack(spacing: 8) {
                    Image(systemName: "doc.text.viewfinder")
                        .font(.system(size: 70))
                        .foregroundColor(.blue)
                    
                    Text("Receipt Share")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)
                }
                
                // 入力フォーム - ダークモード対応
                VStack(spacing: 20) {
                    // メールアドレス入力
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.secondary)
                            .frame(width: 20)
                        TextField("メールアドレス", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .focused($focusField, equals: .email)
                            .submitLabel(.next)
                            .onSubmit {
                                focusField = .password
                            }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.secondarySystemBackground))
                            .shadow(color: Color.primary.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    
                    // パスワード入力
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.secondary)
                            .frame(width: 20)
                        SecureField("パスワード", text: $password)
                            .focused($focusField, equals: .password)
                            .submitLabel(.done)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.secondarySystemBackground))
                            .shadow(color: Color.primary.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    
                    // パスワードを忘れた方はこちら（ログインモードのみ表示）
                    if !isSignUp {
                        HStack {
                            Spacer()
                            Button("パスワードを忘れた方はこちら") {
                                showResetPassword = true
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    
                    // ログインボタン
                    Button(action: {
                        Task {
                            if isSignUp {
                                await authViewModel.signUp(email: email, password: password)
                            } else {
                                await authViewModel.signIn(email: email, password: password)
                            }
                        }
                    }) {
                        Text(isSignUp ? "アカウント作成" : "ログイン")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue)
                            )
                            .shadow(color: Color.blue.opacity(colorScheme == .dark ? 0.2 : 0.4), radius: 5, x: 0, y: 2)
                    }
                    .disabled(email.isEmpty || password.isEmpty || authViewModel.isLoading)
                    .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1.0)
                    
                    // 境界線
                    VStack {
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.secondary.opacity(0.3))
                            
                            Text("または")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.secondary.opacity(0.3))
                        }
                    }
                    .padding(.vertical, 8)
                    
                    GoogleSignInButton(
                        scheme: colorScheme == .dark ? .dark : .light,
                        style: .wide,
                        action: {
                            Task {
                                await authViewModel.signInWithGoogle()
                            }
                        }
                    )
                    .frame(height: 50)
                    .cornerRadius(12)
                    .disabled(authViewModel.isLoading)
                    .opacity(authViewModel.isLoading ? 0.6 : 1.0)
                    
                                         Button(action: {
                         Task {
                             await authViewModel.signInWithApple()
                         }
                     }) {
                         HStack {
                             Image(systemName: "applelogo")
                                 .foregroundColor(.white)
                                 .font(.system(size: 18, weight: .medium))
                             
                             Text("Apple でサインイン")
                                 .foregroundColor(.white)
                                 .font(.system(size: 16, weight: .medium))
                         }
                         .frame(maxWidth: .infinity)
                         .frame(height: 50)
                         .background(Color.black)
                         .cornerRadius(12)
                     }
                     .disabled(authViewModel.isLoading)
                     .opacity(authViewModel.isLoading ? 0.6 : 1.0)
                    
                    // モード切替ボタン
                    Button(action: {
                        withAnimation {
                            isSignUp.toggle()
                            email = ""
                            password = ""
                        }
                    }) {
                        Text(isSignUp ? "既存アカウントでログイン" : "新規アカウント作成")
                            .foregroundColor(.blue)
                            .font(.footnote)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding()
            
            // ローディングオーバーレイ
            if authViewModel.isLoading {
                Color.black.opacity(colorScheme == .dark ? 0.5 : 0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: 15) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    Text(isSignUp ? "アカウント作成中..." : "ログイン中...")
                        .foregroundColor(.white)
                        .font(.headline)
                }
                .padding(25)
                .background(Material.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .alert(authViewModel.errorMessage != nil ? "エラー" : "", isPresented: .constant(authViewModel.errorMessage != nil)) {
            Button("OK") {
                authViewModel.errorMessage = nil
            }
        } message: {
            Text(authViewModel.errorMessage ?? "")
        }
        .sheet(isPresented: $showResetPassword) {
            ResetPasswordView()
        }
        .onAppear {
            authViewModel.observeAuthChanges()
        }
    }
}

#Preview {
    SignInView()
        .environment(AuthViewModel(authRepository: FirebaseAuthRepository()))
}
